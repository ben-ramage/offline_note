import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_note/features/create/data/sync/sync_queue_repository.dart';
import 'package:offline_note/features/create/data/sync/sync_runner.dart';
import 'package:offline_note/features/create/domain/entities/post.dart';
import 'package:offline_note/features/create/domain/entities/sync_types.dart';
import 'package:offline_note/features/create/domain/repos/local_post_repository.dart';
import 'package:offline_note/features/create/presentation/cubits/post_state.dart';

class PostCubit extends Cubit<PostState> {
  final LocalPostRepository localPostRepository;
  final SyncQueueRepository syncQueueRepository;
  final SyncRunner syncRunner;

  StreamSubscription<List<Post>>? _postStreamSubscription;
  int _generation = 0;

  PostCubit({
    required this.localPostRepository,
    required this.syncQueueRepository,
    required this.syncRunner,
  }) : super(PostInitial());

  void startPostsStream(String userId) {
    final normalizedUser = userId.trim();

    if (normalizedUser.isEmpty) {
      _emitError('User ID is required.');
      return;
    }

    final generation = ++_generation;

    final previousSubscription = _postStreamSubscription;
    _postStreamSubscription = null;

    if (previousSubscription != null) {
      unawaited(previousSubscription.cancel());
    }

    _postStreamSubscription = localPostRepository
        .watchPublishedPosts(normalizedUser)
        .listen(
          (posts) {
            if (generation != _generation || isClosed) {
              return;
            }

            emit(PostsLoaded(posts));
          },
          onError: (Object error) {
            if (generation != _generation || isClosed) {
              return;
            }

            _emitError('Posts stream failed: $error');
          },
        );
  }

  Future<bool> publishPost(Post post) async {
    try {
      if (post.id.trim().isEmpty) {
        throw ArgumentError.value(post.id, 'post.id', 'Post ID is required.');
      }

      if (post.userId.trim().isEmpty) {
        throw ArgumentError.value(
          post.userId,
          'post.userId',
          'User ID is required.',
        );
      }

      final localPost = post.copyWith(
        updatedAt: DateTime.now(),
        isDraft: false,
        draftDate: null,
        syncState: LocalSyncState.pending.name,
        pendingAction: PendingAction.publish.name,
        lastSyncError: null,
        isDeleted: false,
      );

      await localPostRepository.upsertPost(localPost);

      await syncQueueRepository.enqueue(
        entityId: localPost.id,
        jobType: SyncJobType.publishPost,
      );

      // The local operation is complete once the Post and queue job exist.
      // Firebase synchronization can continue independently.
      unawaited(_requestSync(localPost.id));

      return true;
    } catch (error) {
      _emitError('Failed to queue post for publishing: $error');

      return false;
    }
  }

  Future<bool> updatePost(Post updatedPost) async {
    try {
      final existingPost = await localPostRepository.getPostById(
        updatedPost.id,
      );

      if (existingPost == null) {
        throw StateError('Post ${updatedPost.id} was not found.');
      }

      if (existingPost.isDraft) {
        throw StateError(
          'Drafts must be published rather than remotely updated.',
        );
      }

      if (existingPost.isDeleted) {
        throw StateError('Deleted posts cannot be updated.');
      }

      if (updatedPost.userId != existingPost.userId) {
        throw StateError('The post owner cannot be changed.');
      }

      // An edit made before the initial publish finishes must remain part of
      // that publish operation rather than becoming a remote update.
      final mustStillPublish =
          existingPost.pendingAction == PendingAction.publish.name ||
          existingPost.syncState == LocalSyncState.localOnly.name;

      final pendingAction = mustStillPublish
          ? PendingAction.publish
          : PendingAction.update;

      final jobType = mustStillPublish
          ? SyncJobType.publishPost
          : SyncJobType.updatePost;

      final localPost = updatedPost.copyWith(
        userId: existingPost.userId,
        createdAt: existingPost.createdAt,
        updatedAt: DateTime.now(),
        isDraft: false,
        draftDate: null,
        syncState: LocalSyncState.pending.name,
        pendingAction: pendingAction.name,
        lastSyncError: null,
        isDeleted: false,
      );

      await localPostRepository.upsertPost(localPost);

      await syncQueueRepository.enqueue(
        entityId: localPost.id,
        jobType: jobType,
      );

      unawaited(_requestSync(localPost.id));

      return true;
    } catch (error) {
      _emitError('Failed to queue post update: $error');

      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      final normalizedPostId = postId.trim();

      if (normalizedPostId.isEmpty) {
        throw ArgumentError.value(postId, 'postId', 'Post ID is required.');
      }

      final post = await localPostRepository.getPostById(normalizedPostId);

      if (post == null) {
        throw StateError('Post $normalizedPostId was not found.');
      }

      if (post.isDraft) {
        throw StateError('Drafts must be deleted through DraftCubit.');
      }

      final deletedPost = post.copyWith(
        updatedAt: DateTime.now(),
        syncState: LocalSyncState.pending.name,
        pendingAction: PendingAction.delete.name,
        lastSyncError: null,
        isDeleted: true,
      );

      await localPostRepository.upsertPost(deletedPost);

      await syncQueueRepository.enqueue(
        entityId: normalizedPostId,
        jobType: SyncJobType.deletePost,
      );

      unawaited(_requestSync(normalizedPostId));

      return true;
    } catch (error) {
      _emitError('Failed to queue post deletion: $error');

      return false;
    }
  }

  Future<bool> retryFailedPost(String postId) async {
    final normalizedPostId = postId.trim();

    try {
      if (normalizedPostId.isEmpty) {
        throw ArgumentError.value(postId, 'postId', 'Post ID is required.');
      }

      final post = await localPostRepository.getPostById(normalizedPostId);

      if (post == null) {
        throw StateError('Post $normalizedPostId was not found.');
      }

      if (post.isDraft) {
        throw StateError('Drafts do not have remote sync jobs.');
      }

      if (post.syncState != LocalSyncState.failed.name) {
        throw StateError(
          'Post $normalizedPostId is not in the failed sync state.',
        );
      }

      final pendingActionValue = post.pendingAction;

      if (pendingActionValue == null) {
        throw StateError(
          'Post $normalizedPostId has no pending action to retry.',
        );
      }

      final pendingAction = PendingActionX.fromValue(pendingActionValue);

      if (pendingAction == PendingAction.none) {
        throw StateError(
          'Post $normalizedPostId has no pending action to retry.',
        );
      }

      // Update the Post first. Its failed queue job prevents the runner from
      // claiming work for this post until the job is moved back to pending.
      await localPostRepository.updateSyncMetadata(
        normalizedPostId,
        syncState: LocalSyncState.pending,
        pendingAction: pendingAction,
        lastSyncError: null,
      );

      try {
        await syncQueueRepository.retryFailedJobForEntity(normalizedPostId);
      } catch (error) {
        // Restore the local failure state if the queue transition fails.
        try {
          await localPostRepository.updateSyncMetadata(
            normalizedPostId,
            syncState: LocalSyncState.failed,
            pendingAction: pendingAction,
            lastSyncError: post.lastSyncError,
          );
        } catch (_) {
          // Preserve the original queue error.
        }

        rethrow;
      }

      unawaited(_requestSync(normalizedPostId));

      return true;
    } catch (error) {
      _emitError('Failed to retry post $normalizedPostId: $error');

      return false;
    }
  }

  Future<bool> discardFailedPost(String postId) async {
    final normalizedPostId = postId.trim();

    try {
      if (normalizedPostId.isEmpty) {
        throw ArgumentError.value(postId, 'postId', 'Post ID is required.');
      }

      final post = await localPostRepository.getPostById(normalizedPostId);

      if (post == null) {
        throw StateError('Post $normalizedPostId was not found.');
      }

      if (post.isDraft) {
        throw StateError('Drafts must be deleted through DraftCubit.');
      }

      if (post.syncState != LocalSyncState.failed.name) {
        throw StateError('Only failed posts can be manually discarded.');
      }

      final deletedPost = post.copyWith(
        updatedAt: DateTime.now(),
        syncState: LocalSyncState.pending.name,
        pendingAction: PendingAction.delete.name,
        lastSyncError: null,
        isDeleted: true,
      );

      // The failed queue job currently blocks this entity, so write the local
      // tombstone before replacing that job with runnable deletion work.
      await localPostRepository.upsertPost(deletedPost);

      try {
        await syncQueueRepository.replaceUnfinishedJobsWithDelete(
          normalizedPostId,
        );
      } catch (error) {
        // Restore the original failed Post if the queue could not be changed.
        try {
          await localPostRepository.upsertPost(post);
        } catch (_) {
          // Preserve the original queue error.
        }

        rethrow;
      }

      unawaited(_requestSync(normalizedPostId));

      return true;
    } catch (error) {
      _emitError('Failed to discard post $normalizedPostId: $error');

      return false;
    }
  }

  Future<void> _requestSync(String postId) async {
    try {
      await syncRunner.runPendingJobs();
    } catch (error) {
      _emitError(
        'Post $postId remains queued, but sync could not start: $error',
      );
    }
  }

  void _emitError(String message) {
    if (!isClosed) {
      emit(PostError(message));
    }
  }

  Future<void> clearStreams() async {
    _generation++;

    final subscription = _postStreamSubscription;
    _postStreamSubscription = null;

    if (subscription != null) {
      await subscription.cancel();
    }

    if (!isClosed) {
      emit(PostInitial());
    }
  }

  @override
  Future<void> close() async {
    _generation++;

    final subscription = _postStreamSubscription;
    _postStreamSubscription = null;

    if (subscription != null) {
      await subscription.cancel();
    }
    return super.close();
  }
}
