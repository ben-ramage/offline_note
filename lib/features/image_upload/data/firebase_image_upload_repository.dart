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
  Future<ImageUpload> uploadImageMobile({
    required String path,
    required String userId,
    required String postId,
  }) async {
    final file = XFile(path);
    final fileBytes = await file.readAsBytes();

    return _uploadImage(fileBytes: fileBytes, userId: userId, postId: postId);
  }

  @override
  Future<ImageUpload> uploadImageWeb({
    required Uint8List fileBytes,
    required String userId,
    required String postId,
  }) async {
    return _uploadImage(fileBytes: fileBytes, userId: userId, postId: postId);
  }

  @override
  Future<void> deleteImage(String storagePath) async {
    final normalizedStoragePath = storagePath.trim();

    if (normalizedStoragePath.trim().isEmpty) {
      return;
    }

    try {
      await storage.ref(normalizedStoragePath).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') {
        rethrow;
      }
    }
  }

  Future<ImageUpload> _uploadImage({
    required Uint8List fileBytes,
    required String userId,
    required String postId,
  }) async {
    if (fileBytes.isEmpty) {
      throw ArgumentError('Image data cannot be empty.');
    }

    final normalizedUserId = userId.trim();
    final normalizedPostId = postId.trim();

    if (normalizedUserId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'User ID is required.');
    }

    if (normalizedPostId.isEmpty) {
      throw ArgumentError.value(postId, 'postId', 'Post ID is required.');
    }

    final compressedBytes = await _compressImage(fileBytes);

    if (compressedBytes.isEmpty) {
      throw Exception('Image compression failed.');
    }

    final storageRef = storage
        .ref()
        .child('images')
        .child(normalizedUserId)
        .child('$normalizedPostId.webp');

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
