import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:offline_note/features/image_upload/domain/entities/image_upload.dart';
import 'package:offline_note/features/image_upload/domain/repos/image_upload_repository.dart';

class FirebaseImageUploadRepository implements ImageUploadRepository {
  final FirebaseStorage storage;

  FirebaseImageUploadRepository({FirebaseStorage? storageInstance})
    : storage = storageInstance ?? FirebaseStorage.instance;

  @override
  Future<ImageUpload> uploadImageMobile(String path, String userId) async {
    final file = XFile(path);
  }

  @override
  Future<ImageUpload> uploadImageWeb(Uint8List fileBytes, String userId) async {
    // TODO: implement uploadImageWeb
    throw UnimplementedError();
  }

  @override
  Future<void> deleteImage(String storagePath) {
    // TODO: implement deleteImage
    throw UnimplementedError();
  }
}
