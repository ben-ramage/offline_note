import 'package:offline_note/features/image_upload/domain/entities/upload_image.dart';

abstract class UploadImageRepository {
  Future<UploadImage> uploadImageMobile(String path, String userId);
  Future<UploadImage> uploadImageWeb(String fileBytes, String userId);
}
