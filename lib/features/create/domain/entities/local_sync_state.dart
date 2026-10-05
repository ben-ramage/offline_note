enum LocalSyncState { localOnly, pending, syncing, synced, failed }

enum PendingAction { publish, update, delete, none }

enum SyncJobType { publishPost, updatePost, deletePost }

enum SyncJobStatus { pending, running, failed, done }

// Extensions

extension LocalSyncStateX on LocalSyncState {
  static LocalSyncState fromValue(String value) {
    return LocalSyncState.values.firstWhere(
      (element) => element.name == value,
      orElse: () => LocalSyncState.localOnly,
    );
  }
}

extension PendingActionX on PendingAction {
  static PendingAction fromValue(String value) {
    return PendingAction.values.firstWhere(
      (element) => element.name == value,
      orElse: () => PendingAction.none,
    );
  }
}

extension SyncJobTypeX on SyncJobType {
  static SyncJobType fromValue(String value) {
    return SyncJobType.values.firstWhere(
      (element) => element.name == value,
      orElse: () => SyncJobType.publishPost,
    );
  }
}

extension SyncJobStatusX on SyncJobStatus {
  static SyncJobStatus fromValue(String value) {
    return SyncJobStatus.values.firstWhere(
      (element) => element.name == value,
      orElse: () => SyncJobStatus.pending,
    );
  }
}
