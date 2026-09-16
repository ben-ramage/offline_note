import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:offline_note/features/image_upload/domain/entities/image_upload.dart';
import 'package:offline_note/features/image_upload/domain/repos/image_upload_repository.dart';

class FirebaseImageUploadRepository implements ImageUploadRepository {
  final FirebaseStorage storage;

  FirebaseImageUploadRepository({FirebaseStorage? storageInstance})
    : storage = storageInstance ?? FirebaseStorage.instance;

  @override
  Future<ImageUpload> uploadImageMobile(String path, String userId) async {
    final file = XFile(path);
    final fileBytes = await file.readAsBytes();

    return _uploadImage(fileBytes: fileBytes, userId: userId);
  }

  @override
  Future<ImageUpload> uploadImageWeb(Uint8List fileBytes, String userId) async {
    return _uploadImage(fileBytes: fileBytes, userId: userId);
  }

  @override
  Future<void> deleteImage(String storagePath) async {
    if (storagePath.trim().isEmpty) {
      return;
    }

    await storage.ref(storagePath).delete();
  }

  Future<ImageUpload> _uploadImage({
    required Uint8List fileBytes,
    required String userId,
  }) async {
    if (fileBytes.isEmpty) {
      throw Exception('Image is empty.');
    }

    final compressedBytes = await _compressImage(fileBytes);

    if (compressedBytes.isEmpty) {
      throw Exception('Image compression failed.');
    }

    final fileName = '${DateTime.now().microsecondsSinceEpoch}.webp';

    final storageRef = storage
        .ref()
        .child('images')
        .child(userId)
        .child(fileName);

    final snapshot = await storageRef.putData(
      compressedBytes,
      SettableMetadata(contentType: 'image/webp'),
    );

    final downloadUrl = await snapshot.ref.getDownloadURL();

    return ImageUpload(
      downloadUrl: downloadUrl,
      storagePath: snapshot.ref.fullPath,
    );
  }

  Future<Uint8List> _compressImage(Uint8List fileBytes) async {
    return FlutterImageCompress.compressWithList(
      fileBytes,
      format: CompressFormat.webp,
      quality: 70,
      minWidth: 800,
      minHeight: 800,
    );
  }
}
