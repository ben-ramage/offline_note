import 'dart:typed_data';

import 'package:offline_note/features/image_upload/domain/entities/image_upload.dart';

abstract class ImageUploadRepository {
  Future<ImageUpload> uploadImageMobile(String path, String userId);
  Future<ImageUpload> uploadImageWeb(Uint8List fileBytes, String userId);
  Future<void> deleteImage(String storagePath);
}
