import 'dart:io';

import 'package:flutter/foundation.dart';

/// Manages ownership of local image files created while editing a draft.
///
/// Drift owns [originalPath] and any image transferred through
/// [finalizeSave] or [markDriftOwned].
///
/// The editor owns every path registered through [track]. Editor-owned
/// images may be deleted when replaced, cancelled, or abandoned.
class DraftImageSession {
  String? _originalPath;

  final Set<String> _ownedPaths = <String>{};

  DraftImageSession(this._originalPath);

  String? get originalPath => _originalPath;

  bool owns(String? filePath) {
    return filePath != null && _ownedPaths.contains(filePath);
  }

  /// Records a completed image file as owned by this editor session.
  void track(String filePath) {
    _ownedPaths.add(filePath);
  }

  /// Deletes [filePath] only when it belongs to this editor session.
  ///
  /// Drift-owned and otherwise untracked paths are preserved.
  Future<void> deleteIfOwned(String? filePath) async {
    if (filePath == null) {
      return;
    }

    if (!_ownedPaths.contains(filePath)) {
      debugPrint('Not deleting non-session image: $filePath');
      return;
    }

    final file = File(filePath);

    debugPrint('Deleting superseded session image: $filePath');
    debugPrint('Exists before deletion: ${await file.exists()}');

    final deleted = await _deleteFileIfExists(filePath);

    debugPrint('Exists after deletion: ${await file.exists()}');

    if (deleted) {
      _ownedPaths.remove(filePath);
    }
  }

  /// Attempts to remove an incomplete or abandoned output.
  ///
  /// If deletion fails, the path remains editor-owned so later cleanup
  /// can make another attempt.
  Future<void> deleteOrRetainOwnership(String filePath) async {
    final deleted = await _deleteFileIfExists(filePath);

    if (deleted) {
      _ownedPaths.remove(filePath);
    } else {
      _ownedPaths.add(filePath);
    }
  }

  /// Deletes every editor-owned image except [preservePath].
  ///
  /// This is used when cancelling the editor or removing obsolete files
  /// after a successful save.
  Future<void> cleanup({String? preservePath}) async {
    for (final filePath in _ownedPaths.toList()) {
      if (filePath == preservePath) {
        continue;
      }

      final deleted = await _deleteFileIfExists(filePath);

      if (deleted) {
        _ownedPaths.remove(filePath);
      }
    }
  }

  /// Transfers [savedPath] to Drift ownership after a successful save.
  ///
  /// Other editor-owned files are removed. The previous Drift-owned image
  /// is deleted only after ownership of the replacement has transferred.
  Future<void> finalizeSave({required String? savedPath}) async {
    final previousOriginalPath = _originalPath;

    if (savedPath != null) {
      _ownedPaths.remove(savedPath);
    }

    await cleanup();

    if (previousOriginalPath != null && previousOriginalPath != savedPath) {
      // Failure here may leave an orphan, but must not invalidate a
      // successful Drift save.
      await _deleteFileIfExists(previousOriginalPath);
    }

    _originalPath = savedPath;
  }

  /// Marks a path as Drift-owned without performing normal cleanup.
  ///
  /// This is a defensive fallback for an unexpected saved-path mismatch.
  void markDriftOwned(String? filePath) {
    if (filePath != null) {
      _ownedPaths.remove(filePath);
    }

    _originalPath = filePath;
  }

  /// Best-effort synchronous fallback for widget disposal.
  ///
  /// Normal cleanup should happen asynchronously before navigation.
  void cleanupSync({String? preservePath}) {
    for (final filePath in _ownedPaths.toList()) {
      if (filePath == preservePath) {
        continue;
      }

      try {
        final file = File(filePath);

        if (file.existsSync()) {
          file.deleteSync();
        }

        _ownedPaths.remove(filePath);
      } catch (error) {
        debugPrint(
          'Could not clean up abandoned image: '
          '$filePath\n$error',
        );
      }
    }
  }

  Future<bool> _deleteFileIfExists(String filePath) async {
    try {
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }

      return true;
    } catch (error) {
      debugPrint('Could not delete local image: $filePath\n$error');

      return false;
    }
  }
}
