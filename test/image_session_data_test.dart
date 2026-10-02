import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:offline_note/features/create/data/local/draft_image_session.dart';

void main() {
  late Directory tempDirectory;

  String testPath(String filename) {
    return '${tempDirectory.path}${Platform.pathSeparator}$filename';
  }

  Future<File> createTestImage(String filename) async {
    final file = File(testPath(filename));

    // The contents do not need to represent a real image because
    // DraftImageSession only manages files and their ownership.
    return file.writeAsBytes(<int>[1, 2, 3]);
  }

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'draft_image_session_test_',
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  group('ownership', () {
    test('track marks a file as owned by the editor session', () async {
      final image = await createTestImage('selected.jpg');
      final session = DraftImageSession(null);

      session.track(image.path);

      expect(session.owns(image.path), isTrue);
    });
  });

  group('deleteIfOwned', () {
    test('deletes an editor-owned file', () async {
      final image = await createTestImage('selected.jpg');
      final session = DraftImageSession(null);

      session.track(image.path);

      await session.deleteIfOwned(image.path);

      expect(await image.exists(), isFalse);
      expect(session.owns(image.path), isFalse);
    });

    test('does not delete an untracked file', () async {
      final image = await createTestImage('untracked.jpg');
      final session = DraftImageSession(null);

      await session.deleteIfOwned(image.path);

      expect(await image.exists(), isTrue);
      expect(session.owns(image.path), isFalse);
    });

    test('does not delete the original Drift-owned image', () async {
      final original = await createTestImage('original.jpg');
      final session = DraftImageSession(original.path);

      await session.deleteIfOwned(original.path);

      expect(await original.exists(), isTrue);
      expect(session.originalPath, original.path);
    });
  });

  group('cleanup', () {
    test('deletes all editor-owned files', () async {
      final first = await createTestImage('first.jpg');
      final second = await createTestImage('second.jpg');
      final session = DraftImageSession(null);

      session.track(first.path);
      session.track(second.path);

      await session.cleanup();

      expect(await first.exists(), isFalse);
      expect(await second.exists(), isFalse);
      expect(session.owns(first.path), isFalse);
      expect(session.owns(second.path), isFalse);
    });

    test('preserves the requested editor-owned file', () async {
      final preserved = await createTestImage('preserved.jpg');
      final discarded = await createTestImage('discarded.jpg');
      final session = DraftImageSession(null);

      session.track(preserved.path);
      session.track(discarded.path);

      await session.cleanup(preservePath: preserved.path);

      expect(await preserved.exists(), isTrue);
      expect(session.owns(preserved.path), isTrue);

      expect(await discarded.exists(), isFalse);
      expect(session.owns(discarded.path), isFalse);
    });

    test('does not delete the original Drift-owned image', () async {
      final original = await createTestImage('original.jpg');
      final temporary = await createTestImage('temporary.jpg');
      final session = DraftImageSession(original.path);

      session.track(temporary.path);

      await session.cleanup();

      expect(await original.exists(), isTrue);
      expect(await temporary.exists(), isFalse);
      expect(session.originalPath, original.path);
    });
  });

  group('finalizeSave', () {
    test(
      'transfers the saved image to Drift and deletes obsolete images',
      () async {
        final original = await createTestImage('original.jpg');
        final replacement = await createTestImage('replacement.jpg');
        final obsolete = await createTestImage('obsolete.jpg');

        final session = DraftImageSession(original.path);

        session.track(replacement.path);
        session.track(obsolete.path);

        await session.finalizeSave(savedPath: replacement.path);

        expect(session.originalPath, replacement.path);

        // The saved replacement survives but is no longer editor-owned.
        expect(await replacement.exists(), isTrue);
        expect(session.owns(replacement.path), isFalse);

        // The previous Drift image and obsolete session image are removed.
        expect(await original.exists(), isFalse);
        expect(await obsolete.exists(), isFalse);
        expect(session.owns(obsolete.path), isFalse);
      },
    );

    test('preserves the existing original when it is saved again', () async {
      final original = await createTestImage('original.jpg');
      final session = DraftImageSession(original.path);

      await session.finalizeSave(savedPath: original.path);

      expect(await original.exists(), isTrue);
      expect(session.originalPath, original.path);
      expect(session.owns(original.path), isFalse);
    });

    test('removes the old original when saved without an image', () async {
      final original = await createTestImage('original.jpg');
      final session = DraftImageSession(original.path);

      await session.finalizeSave(savedPath: null);

      expect(await original.exists(), isFalse);
      expect(session.originalPath, isNull);
    });
  });

  group('markDriftOwned', () {
    test('transfers ownership without cleaning other files', () async {
      final saved = await createTestImage('saved.jpg');
      final other = await createTestImage('other.jpg');
      final session = DraftImageSession(null);

      session.track(saved.path);
      session.track(other.path);

      session.markDriftOwned(saved.path);

      expect(session.originalPath, saved.path);
      expect(session.owns(saved.path), isFalse);
      expect(session.owns(other.path), isTrue);

      expect(await saved.exists(), isTrue);
      expect(await other.exists(), isTrue);
    });
  });

  group('cleanupSync', () {
    test('synchronously deletes all editor-owned files', () async {
      final first = await createTestImage('first.jpg');
      final second = await createTestImage('second.jpg');
      final session = DraftImageSession(null);

      session.track(first.path);
      session.track(second.path);

      session.cleanupSync();

      expect(first.existsSync(), isFalse);
      expect(second.existsSync(), isFalse);
      expect(session.owns(first.path), isFalse);
      expect(session.owns(second.path), isFalse);
    });

    test('synchronously preserves the requested path', () async {
      final preserved = await createTestImage('preserved.jpg');
      final discarded = await createTestImage('discarded.jpg');
      final session = DraftImageSession(null);

      session.track(preserved.path);
      session.track(discarded.path);

      session.cleanupSync(preservePath: preserved.path);

      expect(preserved.existsSync(), isTrue);
      expect(session.owns(preserved.path), isTrue);

      expect(discarded.existsSync(), isFalse);
      expect(session.owns(discarded.path), isFalse);
    });

    test('does not delete the original Drift-owned image', () async {
      final original = await createTestImage('original.jpg');
      final temporary = await createTestImage('temporary.jpg');
      final session = DraftImageSession(original.path);

      session.track(temporary.path);

      session.cleanupSync();

      expect(original.existsSync(), isTrue);
      expect(temporary.existsSync(), isFalse);
    });
  });
}
