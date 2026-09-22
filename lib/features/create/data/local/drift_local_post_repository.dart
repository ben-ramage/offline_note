import 'dart:io';

import 'package:drift/drift.dart';
import 'package:offline_note/features/create/data/local/local_post_database.dart';
import 'package:offline_note/features/create/domain/entities/post.dart';
import 'package:offline_note/features/create/domain/repos/local_post_repository.dart';

class DriftLocalPostRepository implements LocalPostRepository {
  final LocalPostDatabase database;

  DriftLocalPostRepository(this.database);

  @override
  Stream<List<Post>> watchPublishedPosts(String userId) {
    final query = (database.select(database.localPosts)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.isDraft.equals(false) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]));

    return query.watch().map(
      (rows) => rows.map((row) => _mapRowToPost(row)).toList(),
    );
  }

  @override
  Stream<List<Post>> watchDrafts(String userId) {
    final query = (database.select(database.localPosts)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.isDraft.equals(true) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]));

    return query.watch().map(
      (rows) => rows.map((row) => _mapRowToPost(row)).toList(),
    );
  }

  @override
  Future<void> upsertPost(Post post) async {
    await database
        .into(database.localPosts)
        .insertOnConflictUpdate(_mapPostToCompanion(post));
  }

  @override
  Future<Post?> getPostById(String id) async {
    final query = database.select(database.localPosts)
      ..where((tbl) => tbl.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    return _mapRowToPost(row);
  }

  @override
  Future<void> markDeleted(String id) async {
    await (database.update(
      database.localPosts,
    )..where((tbl) => tbl.id.equals(id))).write(
      LocalPostsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Add Mark Sync State Later...

  @override
  Future<void> hardDeleteDraftWithLocalImage(String id) async {
    final draft = await getPostById(id);

    if (draft?.isDraft != true) {
      return;
    }

    final imagePath = draft?.localImagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      final imageFile = File(imagePath);

      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    }
    await hardDeletePost(id);
  }

  @override
  Future<void> hardDeletePost(String id) async {
    await (database.delete(
      database.localPosts,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  LocalPostsCompanion _mapPostToCompanion(Post post) {
    return LocalPostsCompanion(
      id: Value(post.id),
      userId: Value(post.userId),
      title: Value(post.title),
      paragraph: Value(post.paragraph),
      imageUrl: Value(post.imageUrl),
      imageStoragePath: Value(post.imageStoragePath),
      localImagePath: Value(post.localImagePath),
      localImageBytes: Value(post.localImageBytes),
      createdAt: Value(post.createdAt),
      updatedAt: Value(post.updatedAt),
      isDraft: Value(post.isDraft),
      draftDate: Value(post.draftDate),
      syncState: Value(post.syncState),
      pendingAction: Value(post.pendingAction),
      lastSyncError: Value(post.lastSyncError),
      isDeleted: Value(post.isDeleted),
    );
  }

  Post _mapRowToPost(LocalPost row) {
    return Post(
      id: row.id,
      userId: row.userId,
      title: row.title,
      paragraph: row.paragraph,
      imageUrl: row.imageUrl,
      imageStoragePath: row.imageStoragePath,
      localImagePath: row.localImagePath,
      localImageBytes: row.localImageBytes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDraft: row.isDraft,
      draftDate: row.draftDate,
      syncState: row.syncState,
      pendingAction: row.pendingAction,
      lastSyncError: row.lastSyncError,
      isDeleted: row.isDeleted,
    );
  }
}
