import 'package:offline_note/features/create/data/local/local_post_database.dart';
import 'package:offline_note/features/create/domain/entities/local_sync_state.dart';

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
    // Insert pending job
  }

  Future<List<SyncQueueItem>> getPendingJobs() async {
    // Oldest pending jobs first
    return [];
  }

  Future<void> markRunning(int localId) async {
    // pending -> running
  }

  Future<void> markDone(int localId) async {
    // Running -> done
  }

  Future<void> markFailed(int localId, String error) async {
    // Running -> failed
    // Increment attempts++
  }
}
