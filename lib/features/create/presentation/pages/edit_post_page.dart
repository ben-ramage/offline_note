import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:offline_note/features/create/domain/entities/post.dart';
import 'package:offline_note/features/create/presentation/cubits/draft_cubit.dart';
import 'package:offline_note/features/create/presentation/cubits/draft_state.dart';
import 'package:offline_note/features/create/presentation/pages/post_form_content.dart';
import 'package:offline_note/utils/image_rotation_utility.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class EditPostPage extends StatefulWidget {
  final Post? draftToEdit;
  final Post? postToEdit;

  const EditPostPage({super.key, this.draftToEdit, this.postToEdit});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();

  final titleTextController = TextEditingController();
  final paragraphTextController = TextEditingController();

  Uint8List? _webImage;
  File? _imageFile;

  String? _currentDraftId;

  bool _isRotatingImage = false;
  bool _isSavingDraft = false;

  @override
  void initState() {
    super.initState();

    final draft = widget.draftToEdit;
    final post = widget.postToEdit;
    final source = draft ?? post;

    if (source == null) {
      return;
    }

    _currentDraftId = draft?.id;

    titleTextController.text = source.title;
    paragraphTextController.text = source.paragraph;

    if (!kIsWeb && source.localImagePath != null) {
      _imageFile = File(source.localImagePath!);
    }

    if (kIsWeb && source.localImageBytes != null) {
      _webImage = source.localImageBytes;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final result = await picker.pickImage(source: ImageSource.gallery);

    if (result == null) {
      return;
    }

    if (kIsWeb) {
      final bytes = await result.readAsBytes();

      if (!mounted) return;

      setState(() {
        _webImage = bytes;
        _imageFile = null;
      });

      return;
    }

    final copiedFile = await _copyImageToAppStorage(result);

    if (!mounted) return;

    setState(() {
      _imageFile = copiedFile;
      _webImage = null;
    });
  }

  Future<File> _copyImageToAppStorage(XFile image) async {
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

  Post _buildPost({
    required String id,
    required bool isDraft,
    DateTime? draftDate,
  }) {
    final source = widget.draftToEdit ?? widget.postToEdit;

    return Post(
      id: id,
      userId: localUserId,
      title: titleTextController.text.trim(),
      paragraph: paragraphTextController.text.trim(),
      imageUrl: source?.imageUrl,
      imageStoragePath: source?.imageStoragePath,
      localImagePath: kIsWeb ? null : _imageFile?.path,
      localImageBytes: kIsWeb ? _webImage : null,
      createdAt: source?.createdAt ?? DateTime.now(),
      updatedAt: source?.updatedAt,
      isDraft: isDraft,
      draftDate: draftDate,
      syncState: source?.syncState,
      pendingAction: source?.pendingAction,
      lastSyncError: source?.lastSyncError,
      isDeleted: false,
    );
  }

  void _saveDraft() {
    if (_isSavingDraft) {
      return;
    }

    setState(() {
      _isSavingDraft = true;
    });

    _currentDraftId ??= const Uuid().v4();

    final draft = _buildPost(
      id: _currentDraftId!,
      isDraft: true,
      draftDate: widget.draftToEdit?.draftDate ?? DateTime.now(),
    );

    context.read<DraftCubit>().saveDraft(draft);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DraftCubit, DraftState>(
      listener: (context, state) {
        if (state is DraftError) {
          if (mounted) {
            setState(() {
              _isSavingDraft = false;
            });
          }

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }

        if (state is DraftSaved) {
          _currentDraftId = state.draft.id;

          if (mounted) {
            setState(() {
              _isSavingDraft = false;
            });
          }

          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Draft saved.')));

          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.draftToEdit != null
                ? 'Edit Draft'
                : widget.postToEdit != null
                ? 'Edit Post'
                : 'Create Post',
          ),
          actions: [
            IconButton(
              onPressed: (_isSavingDraft || widget.postToEdit != null)
                  ? null
                  : _saveDraft,
              icon: _isSavingDraft
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_alt),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: PostFormContent(
              formKey: _formKey,
              titleTextController: titleTextController,
              paragraphTextController: paragraphTextController,
              imageFile: _imageFile,
              webImage: _webImage,
              onPickImage: _pickImage,
              onRotateImage: _rotateSelectedImage,
              isRotatingImage: _isRotatingImage,
              postToEdit: widget.postToEdit,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleTextController.dispose();
    paragraphTextController.dispose();
    super.dispose();
  }
}
