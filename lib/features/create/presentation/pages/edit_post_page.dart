import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:offline_note/features/create/domain/entities/post.dart';
import 'package:offline_note/utils/image_rotation_utility.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class EditPostPage extends StatefulWidget {
  final Post? draftToEdit;
  final Post? postToEdit;

  const EditPostPage({super.key, this.draftToEdit, this.postToEdit});

  @override
  State createState() => _EditPostPageState();
}

class _EditPostPageState extends State {
  final _formKey = GlobalKey();

  final titleTextController = TextEditingController();
  final paragraphTextController = TextEditingController();

  Uint8List? _webImage;
  File? _imageFile;

  String? _currentDraftId;

  bool _isRotatingImage = false;
  bool _isSavingDraft = false;

  Future _pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);

    if (result != null) {
      if (kIsWeb) {
        final bytes = await result.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFile = null;
        });
      } else {
        setState(() {
          _imageFile = File(result.path);
          _webImage = null;
        });
      }
    }
  }

  Future _copyImageToAppStorage(XFile image) async {
    final appDirectory = await getApplicationSupportDirectory();
    final draftsDirectory = Directory(
      path.join(appDirectory.path, 'draft_images'),
    );
    await draftsDirectory.create(recursive: true);

    final extension = path.extension(image.path).isEmpty
        ? '.jpg'
        : path.extension(image.path);

    final targetPath = path.join(
      draftsDirectory.path,
      '${const Uuid().v4()}$extension',
    );

    return File(image.path).copy(targetPath);
  }

  Future<String> _createPersistentImagePath() async {
    final appDirectory = await getApplicationSupportDirectory();
    final draftsDirectory = Directory(
      path.join(appDirectory.path, 'draft_images'),
    );

    await draftsDirectory.create(recursive: true);

    return path.join(draftsDirectory.path, '${const Uuid().v4()}.jpg');
  }

  Future<void> _rotateSelectedImage() async {
    if (_isRotatingImage || _imageFile == null) return;

    setState(() {
      _isRotatingImage = true;
    });

    try {
      final targetPath = await _createPersistentImagePath();

      final rotatedPath = await rotateMobileImageInBackground(
        path: _imageFile!.path,
        targetPath: targetPath,
        degrees: 90,
      );

      if (!mounted) return;

      setState(() {
        _imageFile = File(rotatedPath);
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not rotate the image. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRotatingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
