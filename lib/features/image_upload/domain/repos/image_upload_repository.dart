import 'dart:typed_data';

import 'package:offline_note/features/image_upload/domain/entities/image_upload.dart';

abstract class ImageUploadRepository {
  Future<ImageUpload> uploadImageMobile({
    required String path,
    required String userId,
    required String postId,
  });
  Future<ImageUpload> uploadImageWeb({
    required Uint8List fileBytes,
    required String userId,
    required String postId,
  });
  Future<void> deleteImage(String storagePath);
}
