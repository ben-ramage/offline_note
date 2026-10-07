import 'package:offline_note/features/create/domain/entities/post.dart';

abstract class RemotePostRepository {
  Stream<List<Post>> watchPosts(String userId);
  Future<void> publishPost(Post post);
  Future<void> updatePost(Post post);
  Future<void> deletePost({required String postId, required String userId});
}
