import 'package:drift/drift.dart';
import 'package:offline_note/features/create/data/local/local_post_database.dart';
import 'package:offline_note/features/create/domain/entities/sync_types.dart';

class SyncQueueItem {
  final int localId;
  final String entityId;
  final SyncJobType jobType;
  final SyncJobStatus status;
  final int attemptCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SyncQueueItem({
    required this.localId,
    required this.entityId,
    required this.jobType,
    required this.status,
    required this.attemptCount,
    required this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
}

class SyncQueueRepository {
  final LocalPostDatabase database;

  SyncQueueRepository(this.database);

  Future<void> enqueue({
    required String entityId,
    required SyncJobType jobType,
  }) async {
    await database.transaction(() async {
      final existingPending =
          await (database.select(database.syncJobs)
                ..where(
                  (tbl) =>
                      tbl.entityId.equals(entityId) &
                      tbl.status.equals(SyncJobStatus.pending.name),
                )
                ..orderBy([(tbl) => OrderingTerm.asc(tbl.localId)])
                ..limit(1))
              .getSingleOrNull();

      final now = DateTime.now();

      if (existingPending == null) {
        await database
            .into(database.syncJobs)
            .insert(
              SyncJobsCompanion.insert(
                entityId: entityId,
                jobType: jobType.name,
                status: SyncJobStatus.pending.name,
                createdAt: now,
                updatedAt: now,
              ),
            );

        return;
      }

      final existingType = SyncJobTypeX.fromValue(existingPending.jobType);
      final effectiveType = _coalesce(existingType, jobType);

      // The existing pending job already represents the required work.
      if (effectiveType == existingType) {
        return;
      }

      await (database.update(
        database.syncJobs,
      )..where((tbl) => tbl.localId.equals(existingPending.localId))).write(
        SyncJobsCompanion(
          jobType: Value(effectiveType.name),
          updatedAt: Value(now),
        ),
      );
    });
  }

  // Private Helper...
  SyncJobType _coalesce(SyncJobType existing, SyncJobType incoming) {
    // Nothing should replace a pending deletion.
    if (existing == SyncJobType.deletePost) {
      return SyncJobType.deletePost;
    }

    // Deletion supersedes pending publishes and updates.
    if (incoming == SyncJobType.deletePost) {
      return SyncJobType.deletePost;
    }

    // A publish reads the latest Post from Drift, so a subsequent update
    // does not require another queue job.
    if (existing == SyncJobType.publishPost) {
      return SyncJobType.publishPost;
    }

    // Multiple pending updates collapse into one.
    if (existing == SyncJobType.updatePost &&
        incoming == SyncJobType.updatePost) {
      return SyncJobType.updatePost;
    }

    // Handles unusual combos such as update followed by publish.
    return incoming;
  }

  Future<SyncQueueItem?> claimNextPending() async {
    return database.transaction(() async {
      final row =
          await (database.select(database.syncJobs)
                ..where((tbl) => tbl.status.equals(SyncJobStatus.pending.name))
                ..orderBy([
                  (tbl) => OrderingTerm.asc(tbl.createdAt),
                  (tbl) => OrderingTerm.asc(tbl.localId),
                ])
                ..limit(1))
              .getSingleOrNull();

      if (row == null) {
        return null;
      }

      final now = DateTime.now();

      final updatedRows =
          await (database.update(database.syncJobs)..where(
                (tbl) =>
                    tbl.localId.equals(row.localId) &
                    tbl.status.equals(SyncJobStatus.pending.name),
              ))
              .write(
                SyncJobsCompanion(
                  status: Value(SyncJobStatus.running.name),
                  updatedAt: Value(now),
                ),
              );
      if (updatedRows == 0) {
        return null;
      }

      final claimedRow = await (database.select(
        database.syncJobs,
      )..where((tbl) => tbl.localId.equals(row.localId))).getSingle();

      return _mapRow(claimedRow);
    });
  }

  Future<void> markDone(int localId) async {
    final updatedRows =
        await (database.update(database.syncJobs)..where(
              (tbl) =>
                  tbl.localId.equals(localId) &
                  tbl.status.equals(SyncJobStatus.running.name),
            ))
            .write(
              SyncJobsCompanion(
                status: Value(SyncJobStatus.done.name),
                lastError: const Value(null),
                updatedAt: Value(DateTime.now()),
              ),
            );

    if (updatedRows == 0) {
      throw StateError(
        'Cannot mark sync job $localId as done because it is not running.',
      );
    }
  }

  Future<void> markFailed(int localId, String error) async {
    await database.transaction(() async {
      final current =
          await (database.select(database.syncJobs)..where(
                (tbl) =>
                    tbl.localId.equals(localId) &
                    tbl.status.equals(SyncJobStatus.running.name),
              ))
              .getSingleOrNull();

      if (current == null) {
        throw StateError(
          'Cannot mark sync job $localId as failed because it is not running.',
        );
      }

      final updatedRows =
          await (database.update(database.syncJobs)..where(
                (tbl) =>
                    tbl.localId.equals(localId) &
                    tbl.status.equals(SyncJobStatus.running.name),
              ))
              .write(
                SyncJobsCompanion(
                  status: Value(SyncJobStatus.failed.name),
                  attemptCount: Value(current.attemptCount + 1),
                  lastError: Value(error),
                  updatedAt: Value(DateTime.now()),
                ),
              );

      if (updatedRows == 0) {
        throw StateError(
          'Sync job $localId changed before it could be marked as failed.',
        );
      }
    });
  }

  Future<void> retryFailedJobs() async {
    await (database.update(
      database.syncJobs,
    )..where((tbl) => tbl.status.equals(SyncJobStatus.failed.name))).write(
      SyncJobsCompanion(
        status: Value(SyncJobStatus.pending.name),
        lastError: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> recoverStaleRunningJobs() async {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 10));

    await (database.update(database.syncJobs)..where(
          (tbl) =>
              tbl.status.equals(SyncJobStatus.running.name) &
              tbl.updatedAt.isSmallerThanValue(cutoff),
        ))
        .write(
          SyncJobsCompanion(
            status: Value(SyncJobStatus.pending.name),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  SyncQueueItem _mapRow(SyncJob row) {
    return SyncQueueItem(
      localId: row.localId,
      entityId: row.entityId,
      jobType: SyncJobTypeX.fromValue(row.jobType),
      status: SyncJobStatusX.fromValue(row.status),
      attemptCount: row.attemptCount,
      lastError: row.lastError,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
