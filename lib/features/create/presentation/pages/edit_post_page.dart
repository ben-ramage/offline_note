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
  String? _originalLocalImagePath;
  String? _saveRequestId;
  String? _submittedLocalImagePath;

  final Set<String> _sessionImagePaths = <String>{};

  bool _isPickingImage = false;
  bool _isRotatingImage = false;
  bool _isSavingDraft = false;
  bool _isClosing = false;
  bool _hasImageStateConflict = false;
  bool _allowPop = false;

  bool get _isImageBusy => _isPickingImage || _isRotatingImage;

  bool get _isEditorBusy =>
      _isPickingImage ||
      _isRotatingImage ||
      _isSavingDraft ||
      _isClosing ||
      _hasImageStateConflict;

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
      _originalLocalImagePath = source.localImagePath;
      _imageFile = File(source.localImagePath!);
    }

    if (kIsWeb && source.localImageBytes != null) {
      _webImage = source.localImageBytes;
    }
  }

  Future<void> _pickImage() async {
    if (_isEditorBusy || widget.postToEdit != null) {
      return;
    }

    setState(() {
      _isPickingImage = true;
    });

    try {
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

      final previousPath = _imageFile?.path;

      final copiedFile = await _copyImageToAppStorage(result);

      if (!mounted) {
        await _deleteFileIfExists(copiedFile.path);
        return;
      }

      // Record ownership before presenting the image
      _sessionImagePaths.add(copiedFile.path);

      setState(() {
        _imageFile = copiedFile;
        _webImage = null;
      });

      // Delete the previous image only if it was editor-owned.
      // The original Drift-owned image is therefore preserved.
      await _deleteSessionImage(previousPath);
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint('Could not pick image:\n$error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not select the image. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
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

    try {
      return await File(image.path).copy(targetPath);
    } catch (_) {
      // A failed copy may leave an incomplete output.
      await _deleteFailedOutputOrTrack(targetPath);
      rethrow;
    }
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
    if (_isEditorBusy || _imageFile == null || widget.postToEdit != null) {
      return;
    }

    final currentImage = _imageFile!;

    setState(() {
      _isRotatingImage = true;
    });

    String? targetPath;

    try {
      targetPath = await _createPersistentImagePath();

      final rotatedPath = await rotateMobileImageInBackground(
        path: currentImage.path,
        targetPath: targetPath,
        degrees: 90,
      );

      // Nothing owns this output, so delete it immediately.
      if (!mounted) {
        await _deleteFileIfExists(rotatedPath);
        return;
      }

      // Record ownership before presenting the rotated image.
      _sessionImagePaths.add(rotatedPath);

      setState(() {
        _imageFile = File(rotatedPath);
      });

      await _deleteSessionImage(currentImage.path);
    } catch (error) {
      // Rotation may fail after creating an empty or partial output.
      if (targetPath != null) {
        await _deleteFailedOutputOrTrack(targetPath);
      }

      if (!mounted) {
        return;
      }

      debugPrint('Could not rotate image: \n$error');

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

  Future<bool> _deleteFileIfExists(String filePath) async {
    try {
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }

      return true;
    } catch (error) {
      debugPrint('Could not delete local image: $filePath\n$error');

      return false;
    }
  }

  Future<void> _deleteFailedOutputOrTrack(String filePath) async {
    final deleted = await _deleteFileIfExists(filePath);

    if (deleted) {
      _sessionImagePaths.remove(filePath);
    } else {
      // Retain ownership so normal cancellation/dispose cleanup
      // can make another deletion attempt.
      _sessionImagePaths.add(filePath);
    }
  }

  Future<void> _deleteSessionImage(String? filePath) async {
    if (filePath == null) {
      return;
    }

    if (!_sessionImagePaths.contains(filePath)) {
      return;
    }

    final deleted = await _deleteFileIfExists(filePath);

    // Do not forget paths whose deletion failed.
    if (deleted) {
      _sessionImagePaths.remove(filePath);
    }
  }

  Future<void> _cleanupSessionImages({String? preservePath}) async {
    for (final filePath in _sessionImagePaths.toList()) {
      if (filePath == preservePath) {
        continue;
      }

      final deleted = await _deleteFileIfExists(filePath);

      // Keep ownership when deletion fails so cleanup can be retried.
      if (deleted) {
        _sessionImagePaths.remove(filePath);
      }
    }
  }

  Future<void> _finalizeImagesAfterDraftSave(Post savedDraft) async {
    final savedPath = savedDraft.localImagePath;
    final originalPath = _originalLocalImagePath;

    if (!kIsWeb) {
      // The saved image now belongs to Drift.
      // Remove it from editor ownership without deleting it.
      if (savedPath != null) {
        _sessionImagePaths.remove(savedPath);
      }

      // All other files created by this editor are obsolete.
      await _cleanupSessionImages();

      // Drift already references the replacement.
      //
      // Failure to remove the original creates an orphan, but must not
      // invalidate the successful save or delete the replacement.
      if (originalPath != null && originalPath != savedPath) {
        await _deleteFileIfExists(originalPath);
      }
    }

    _originalLocalImagePath = savedPath;
    _submittedLocalImagePath = null;
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
    if (_isEditorBusy || widget.postToEdit != null) {
      return;
    }

    // Require valid title and paragraph fields before saving.
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    _currentDraftId ??= const Uuid().v4();

    final draft = _buildPost(
      id: _currentDraftId!,
      isDraft: true,
      draftDate: widget.draftToEdit?.draftDate ?? DateTime.now(),
    );

    final requestId = const Uuid().v4();

    // Capture exactly what this operation submitted.
    _saveRequestId = requestId;
    _submittedLocalImagePath = draft.localImagePath;

    setState(() {
      _isSavingDraft = true;
    });

    context.read<DraftCubit>().saveDraft(draft, requestId: requestId);
  }

  Future<void> _handleDraftState(DraftState state) async {
    if (state is DraftSaveFailed) {
      final belongsToThisSave =
          _isSavingDraft &&
          state.draftId == _currentDraftId &&
          state.requestId == _saveRequestId;

      if (!belongsToThisSave) {
        return;
      }

      _saveRequestId = null;
      _submittedLocalImagePath = null;

      if (!mounted) {
        return;
      }

      setState(() {
        _isSavingDraft = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message)));

      return;
    }

    if (state is! DraftSaved) {
      return;
    }

    final belongsToThisSave =
        _isSavingDraft &&
        state.draft.id == _currentDraftId &&
        state.requestId == _saveRequestId;

    if (!belongsToThisSave) {
      return;
    }

    // Capture both paths before clearing the active save state.
    final submittedPath = _submittedLocalImagePath;
    final savedPath = state.draft.localImagePath;

    if (savedPath != submittedPath) {
      if (savedPath != null) {
        _sessionImagePaths.remove(savedPath);
      }

      _originalLocalImagePath = savedPath;
      _saveRequestId = null;
      _submittedLocalImagePath = null;

      debugPrint(
        'Draft saved with an unexpected local image path. '
        'Expected: ${submittedPath ?? 'null'}, '
        'saved: ${savedPath ?? 'null'}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSavingDraft = false;
        _hasImageStateConflict = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Draft saved, but its image state was unexpected. '
            'Please close and reopen the draft.',
          ),
        ),
      );

      return;
    }

    _currentDraftId = state.draft.id;

    await _finalizeImagesAfterDraftSave(state.draft);

    _saveRequestId = null;

    if (!mounted) {
      return;
    }

    setState(() {
      _isSavingDraft = false;
      _allowPop = true;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Draft saved.')));

    _schedulePopAfterRebuild();
  }

  // Cleans editor-owned images before allowing the route to close.
  Future<void> _handleBackNavigation() async {
    if (_isClosing) {
      return;
    }

    // Do not leave while Drift is saving or an image operation is running.
    if (_isSavingDraft || _isImageBusy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSavingDraft
                ? 'Please wait for the draft to finish saving.'
                : 'Please wait for the image operation to finish.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isClosing = true;
    });

    // Delete only files created and owned by this editor session.
    await _cleanupSessionImages();

    if (!mounted) {
      return;
    }

    setState(() {
      _allowPop = true;
    });
    _schedulePopAfterRebuild();
  }

  void _schedulePopAfterRebuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    });
  }

  void _cleanupSessionImageSync({String? preservePath}) {
    for (final filePath in _sessionImagePaths.toList()) {
      if (filePath == preservePath) {
        continue;
      }

      try {
        final file = File(filePath);

        if (file.existsSync()) {
          file.deleteSync();
        }

        _sessionImagePaths.remove(filePath);
      } catch (error) {
        debugPrint(
          'Could not clean up abandoned image: '
          '$filePath\n$error',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: ((didPop, result) async {
        if (didPop) {
          return;
        }

        await _handleBackNavigation();
      }),
      child: BlocListener<DraftCubit, DraftState>(
        listener: (_, state) async {
          await _handleDraftState(state);
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
                onPressed: (_isEditorBusy || widget.postToEdit != null)
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
      ),
    );
  }

  @override
  void dispose() {
    _cleanupSessionImageSync(
      preservePath: _isSavingDraft ? _submittedLocalImagePath : null,
    );
    titleTextController.dispose();
    paragraphTextController.dispose();
    super.dispose();
  }
}
