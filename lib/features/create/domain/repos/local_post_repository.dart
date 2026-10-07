import 'package:offline_note/features/create/domain/entities/post.dart';
import 'package:offline_note/features/create/domain/entities/sync_types.dart';

abstract class LocalPostRepository {
  Stream<List<Post>> watchPublishedPosts(String userId);
  Stream<List<Post>> watchDrafts(String userId);
  Stream<List<Post>> watchPendingPosts(String userId);

  Future<void> upsertPost(Post post);
  Future<Post?> getPostById(String id);

  Future<void> updateSyncMetadata(
    String id, {
    required LocalSyncState syncState,
    required PendingAction pendingAction,
    required String? lastSyncError,
  });

  Future<void> markDeleted(String id);
  Future<void> hardDeleteDraftWithLocalImage(String id);
  Future<void> hardDeletePost(String id);
}
