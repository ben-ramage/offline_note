import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:offline_note/features/create/domain/entities/post.dart';
import 'package:offline_note/features/create/domain/repos/remote_post_repository.dart';

class FirebaseRemotePostRepository implements RemotePostRepository {
  final FirebaseFirestore firestore;

  FirebaseRemotePostRepository({FirebaseFirestore? firestoreInstance})
    : firestore = firestoreInstance ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userPosts(String userId) {
    _ensureUserId(userId);

    return firestore.collection('users').doc(userId).collection('posts');
  }

  @override
  Stream<List<Post>> watchPosts(String userId) {
    return _userPosts(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((document) {
            return Post.fromJson({
              ..._withDartDates(document.data()),
              'id': document.id,
              'userId': userId,
            });
          }).toList(),
        );
  }

  @override
  Future<void> publishPost(Post post) async {
    _ensurePublishable(post);

    await _userPosts(post.userId).doc(post.id).set({
      ..._postFields(post),
      'id': post.id,
      'userId': post.userId,

      // Preserve the original creation time across retries.
      'createdAt': Timestamp.fromDate(post.createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updatePost(Post post) async {
    _ensurePublishable(post);

    await _userPosts(post.userId).doc(post.id).update({
      ..._postFields(post),
      'id': post.id,
      'userId': post.userId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deletePost({
    required String postId,
    required String userId,
  }) async {
    _ensureUserId(userId);

    if (postId.trim().isEmpty) {
      throw ArgumentError.value(postId, 'postId', 'Post ID is required.');
    }

    await _userPosts(userId).doc(postId).delete();
  }

  Map<String, dynamic> _postFields(Post post) {
    final data = Map<String, dynamic>.from(post.toRemoteJson());

    // Dates are written explicitly using Firestore-compatible values.
    data.remove('createdAt');
    data.remove('updatedAt');

    return data;
  }

  Map<String, dynamic> _withDartDates(Map<String, dynamic> data) {
    return {
      ...data,
      'createdAt': _convertTimestamp(data['createdAt']),
      'updatedAt': _convertTimestamp(data['updatedAt']),
    };
  }

  Object? _convertTimestamp(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return value;
  }

  void _ensurePublishable(Post post) {
    _ensureUserId(post.userId);

    if (post.id.trim().isEmpty) {
      throw ArgumentError.value(post.id, 'post.id', 'Post ID is required.');
    }

    if (post.isDraft) {
      throw StateError('Draft posts cannot be written remotely.');
    }

    if (post.isDeleted) {
      throw StateError('Deleted posts cannot be published or updated.');
    }

    final title = post.title.trim();

    if (title.isEmpty) {
      throw StateError('A post title is required.');
    }

    if (title.length > 80) {
      throw StateError('Post title must be 80 characters or less.');
    }

    final paragraph = post.paragraph.trim();

    if (paragraph.isEmpty) {
      throw StateError('A post paragraph is required.');
    }

    if (paragraph.length > 1000) {
      throw StateError('Post paragraph must be 1000 characters or less.');
    }
  }

  void _ensureUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'User ID is required.');
    }
  }
}
