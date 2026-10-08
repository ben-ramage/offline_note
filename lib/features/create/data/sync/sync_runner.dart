import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:offline_note/features/create/data/sync/sync_queue_repository.dart';
import 'package:offline_note/features/create/domain/entities/post.dart';
import 'package:offline_note/features/create/domain/entities/sync_types.dart';
import 'package:offline_note/features/create/domain/repos/local_post_repository.dart';
import 'package:offline_note/features/create/domain/repos/remote_post_repository.dart';
import 'package:offline_note/features/image_upload/domain/entities/image_upload.dart';
import 'package:offline_note/features/image_upload/domain/repos/image_upload_repository.dart';

class SyncRunner {
  final LocalPostRepository localPostRepository;
  final SyncQueueRepository syncQueueRepository;
  final RemotePostRepository remotePostRepository;
  final ImageUploadRepository imageUploadRepository;
  final Connectivity connectivity;

  bool _isRunning = false;

  bool get isRunning => _isRunning;

  SyncRunner({
    required this.localPostRepository,
    required this.syncQueueRepository,
    required this.remotePostRepository,
    required this.imageUploadRepository,
    Connectivity? connectivity,
  }) : connectivity = connectivity ?? Connectivity();

  Future<void> runPendingJob() async {
    if (_isRunning) {
      return;
    }

    _isRunning = true;

    try {
      await syncQueueRepository.recoverStaleRunningJobs();

      final connectivityResults = await connectivity.checkConnectivity();

      if (connectivityResults.contains(ConnectivityResult.none)) {
        return;
      }

      while (true) {
        final job = await syncQueueRepository.claimNextPending();

        if (job == null) {
          break;
        }

        await _processClaimedJob(job);
      }

      await syncQueueRepository.deleteCompletedJobs();
    } finally {
      _isRunning = false;
    }
  }

  Future<void> _processClaimedJob(SyncQueueItem job) async {
    try {
      switch (job.jobType) {
        case SyncJobType.publishPost:
          await _handlePublishPost(job.entityId);

        case SyncJobType.updatePost:
          await _handleUpdatePost(job.entityId);

        case SyncJobType.deletePost:
          await _handleDeletePost(job.entityId);
      }

      await syncQueueRepository.markDone(job.localId);
    } catch (error) {
      final errorMessage = error.toString();

      await syncQueueRepository.markFailed(job.localId, errorMessage);

      final post = await localPostRepository.getPostById(job.entityId);

      if (post != null) {
        await localPostRepository.updateSyncMetadata(
          job.entityId,
          syncState: LocalSyncState.failed,
          pendingAction: _pendingActionFor(job.jobType),
          lastSyncError: errorMessage,
        );
      }
    }
  }

  Future<void> _handlePublishPost(String postId) async {
    final post = await localPostRepository.getPostById(postId);

    // The post may have been removed or superseded by a deletion while the
    // publish job was waiting. The stale job can be completed safely.
    if (post == null || post.isDeleted) {
      return;
    }

    if (post.isDraft) {
      throw StateError('Draft post $postId cannot be published.');
    }

    await localPostRepository.updateSyncMetadata(
      postId,
      syncState: LocalSyncState.syncing,
      pendingAction: PendingAction.publish,
      lastSyncError: null,
    );

    final syncingPost = post.copyWith(
      syncState: LocalSyncState.syncing.name,
      pendingAction: PendingAction.publish.name,
      lastSyncError: null,
    );

    final postForRemote = await _uploadImageIfNeeded(syncingPost);

    await remotePostRepository.publishPost(postForRemote);

    await localPostRepository.updateSyncMetadata(
      postId,
      syncState: LocalSyncState.synced,
      pendingAction: PendingAction.none,
      lastSyncError: null,
    );
  }

  Future<void> _handleUpdatePost(String postId) async {
    final post = await localPostRepository.getPostById(postId);

    // This update may have been superseded by a later deletion.
    if (post == null || post.isDeleted) {
      return;
    }

    if (post.isDraft) {
      throw StateError('Draft post $postId cannot be updated remotely.');
    }

    await localPostRepository.updateSyncMetadata(
      postId,
      syncState: LocalSyncState.syncing,
      pendingAction: PendingAction.update,
      lastSyncError: null,
    );

    final syncingPost = post.copyWith(
      syncState: LocalSyncState.syncing.name,
      pendingAction: PendingAction.update.name,
      lastSyncError: null,
    );

    final postForRemote = await _uploadImageIfNeeded(syncingPost);

    await remotePostRepository.updatePost(postForRemote);

    await localPostRepository.updateSyncMetadata(
      postId,
      syncState: LocalSyncState.synced,
      pendingAction: PendingAction.none,
      lastSyncError: null,
    );
  }

  Future<void> _handleDeletePost(String postId) async {
    final post = await localPostRepository.getPostById(postId);

    // This can happen if a previous attempt completed the local deletion
    // but the app stopped before the queue job was marked done.
    if (post == null) {
      return;
    }

    if (post.isDraft) {
      throw StateError(
        'Draft post $postId should be deleted locally, not synchronized.',
      );
    }

    await localPostRepository.updateSyncMetadata(
      postId,
      syncState: LocalSyncState.syncing,
      pendingAction: PendingAction.delete,
      lastSyncError: null,
    );

    await remotePostRepository.deletePost(postId: post.id, userId: post.userId);

    final storagePath = post.imageStoragePath?.trim();

    if (storagePath != null && storagePath.isNotEmpty) {
      await imageUploadRepository.deleteImage(storagePath);
    }

    await localPostRepository.hardDeletePost(postId);
  }

  Future<Post> _uploadImageIfNeeded(Post post) async {
    final imageUrl = post.imageUrl?.trim();
    final storagePath = post.imageStoragePath?.trim();

    final imageAlreadyUploaded =
        imageUrl != null &&
        imageUrl.isNotEmpty &&
        storagePath != null &&
        storagePath.isNotEmpty;

    if (imageAlreadyUploaded) {
      return post;
    }

    ImageUpload? uploadedImage;

    final localImageBytes = post.localImageBytes;

    if (localImageBytes != null && localImageBytes.isNotEmpty) {
      uploadedImage = await imageUploadRepository.uploadImageWeb(
        fileBytes: localImageBytes,
        userId: post.userId,
        postId: post.id,
      );
    } else {
      final localImagePath = post.localImagePath?.trim();

      if (localImagePath != null && localImagePath.isNotEmpty) {
        uploadedImage = await imageUploadRepository.uploadImageMobile(
          path: localImagePath,
          userId: post.userId,
          postId: post.id,
        );
      }
    }

    // Images are optional, so a post without local or remote image data can
    // still be synchronized.
    if (uploadedImage == null) {
      return post;
    }

    if (uploadedImage.downloadUrl.trim().isEmpty) {
      throw StateError(
        'Image upload did not return a download URL for post ${post.id}.',
      );
    }

    if (uploadedImage.storagePath.trim().isEmpty) {
      throw StateError(
        'Image upload did not return a storage path for post ${post.id}.',
      );
    }

    final postWithRemoteImage = post.copyWith(
      imageUrl: uploadedImage.downloadUrl,
      imageStoragePath: uploadedImage.storagePath,
      lastSyncError: null,
    );

    // Persist the upload result before calling Firestore. If the Firestore
    // write fails, the retry can reuse the uploaded image.
    await localPostRepository.upsertPost(postWithRemoteImage);

    return postWithRemoteImage;
  }

  PendingAction _pendingActionFor(SyncJobType jobType) {
    return switch (jobType) {
      SyncJobType.publishPost => PendingAction.publish,
      SyncJobType.updatePost => PendingAction.update,
      SyncJobType.deletePost => PendingAction.delete,
    };
  }
}
