import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:offline_note/features/create/domain/entities/post.dart';

class PostFormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController titleTextController;
  final TextEditingController paragraphTextController;

  final File? imageFile;
  final Uint8List? webImage;

  final VoidCallback onPickImage;
  final VoidCallback onRotateImage;

  final bool isRotatingImage;

  final Post? postToEdit;

  const PostFormContent({
    super.key,
    required this.formKey,
    required this.titleTextController,
    required this.paragraphTextController,
    this.imageFile,
    this.webImage,
    required this.onPickImage,
    required this.onRotateImage,
    required this.isRotatingImage,
    this.postToEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isEditingPost = postToEdit != null;

    final hasNetworkImage =
        postToEdit?.imageUrl != null && postToEdit!.imageUrl!.isNotEmpty;

    final canPickImage = !isEditingPost;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!kIsWeb && imageFile != null && !isEditingPost) ...[
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: isRotatingImage ? null : onRotateImage,
                icon: isRotatingImage
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.rotate_right),
              ),
            ),
            const SizedBox(height: 8.0),
          ],

          GestureDetector(
            onTap: canPickImage ? onPickImage : null,
            child: Stack(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: imageFile != null
                        ? DecorationImage(
                            image: FileImage(imageFile!),
                            fit: BoxFit.cover,
                          )
                        : webImage != null
                        ? DecorationImage(
                            image: MemoryImage(webImage!),
                            fit: BoxFit.cover,
                          )
                        : hasNetworkImage
                        ? DecorationImage(
                            image: NetworkImage(postToEdit!.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child:
                      imageFile == null && webImage == null && !hasNetworkImage
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to add an image',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),

                if (isEditingPost)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lock, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: titleTextController,
            maxLength: 80,
            decoration: const InputDecoration(
              labelText: 'Title:',
              labelStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
              counterText: '',
            ),
            validator: (value) {
              final title = value?.trim() ?? '';

              if (title.isEmpty) {
                return 'Please enter a title';
              }

              if (title.length > 80) {
                return 'Title must be 80 characters or less';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: paragraphTextController,
            maxLength: 1000,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Paragraph:',
              labelStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
              counterText: '',
              alignLabelWithHint: true,
            ),
            validator: (value) {
              final paragraph = value?.trim() ?? '';

              if (paragraph.isEmpty) {
                return 'Please enter a paragraph';
              }

              if (paragraph.length > 1000) {
                return 'Paragraph must be 1000 characters or less';
              }

              return null;
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
