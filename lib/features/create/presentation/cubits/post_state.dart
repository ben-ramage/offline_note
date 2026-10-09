import 'package:offline_note/features/create/domain/entities/post.dart';
import 'package:offline_note/features/create/domain/entities/sync_types.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostsLoaded extends PostState {
  final List<Post> posts;

  PostsLoaded(this.posts);

  List<Post> get pendingPosts {
    return posts.where((post) {
      return post.syncState == LocalSyncState.pending.name ||
          post.syncState == LocalSyncState.syncing.name ||
          post.syncState == LocalSyncState.failed.name;
    }).toList();
  }
}

class PostError extends PostState {
  final String message;

  PostError(this.message);
}
