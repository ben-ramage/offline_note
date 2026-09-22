import 'package:offline_note/features/create/domain/entities/post.dart';

abstract class LocalPostRepository {
  Stream<List<Post>> watchPublishedPosts(String userId);
  Stream<List<Post>> watchDrafts(String userId);
  Future<void> upsertPost(Post post);
  Future<Post?> getPostById(String id);
  Future<void> markDeleted(String id);
  Future<void> hardDeleteDraftWithLocalImage(String id);
  Future<void> hardDeletePost(String id);
}
