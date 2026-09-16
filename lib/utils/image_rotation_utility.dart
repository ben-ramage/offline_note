import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageRotationUtility {
  static Future<String> rotateMobileFile({
    required String path,
    required String targetPath,
    required int degrees,
  }) async {
    final file = File(path);

    if (!await file.exists()) {
      throw Exception('File not found at $path');
    }

    final normalizedDegrees = degrees % 360;

    if (![0, 90, 180, 270].contains(normalizedDegrees)) {
      throw ArgumentError('Rotation must be 0, 90, 180, or 270 degrees.');
    }

    if (normalizedDegrees == 0) {
      return path;
    }

    final bytes = await file.readAsBytes();
    final decodedImage = img.decodeImage(bytes);

    if (decodedImage == null) {
      throw Exception('Could not decode image.');
    }

    final rotatedImage = img.copyRotate(decodedImage, angle: normalizedDegrees);

    final rotatedBytes = Uint8List.fromList(
      img.encodeJpg(rotatedImage, quality: 90),
    );

    final rotatedFile = File(targetPath);

    await rotatedFile.parent.create(recursive: true);

    await rotatedFile.writeAsBytes(rotatedBytes, flush: true);

    return rotatedFile.path;
  }
}

Future<String> rotateMobileImageInBackground({
  required String path,
  required String targetPath,
  required int degrees,
}) {
  return compute(_rotateMobileImageTask, {
    'path': path,
    'targetPath': targetPath,
    'degrees': degrees,
  });
}

Future<String> _rotateMobileImageTask(Map<String, Object> args) {
  return ImageRotationUtility.rotateMobileFile(
    path: args['path'] as String,
    targetPath: args['targetPath'] as String,
    degrees: args['degrees'] as int,
  );
}
