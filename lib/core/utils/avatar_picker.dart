import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Shows a "Camera / Gallery" action sheet and returns the picked image
/// file, downscaled to keep avatar uploads small. Returns null if the user
/// backs out at either step.
Future<File?> pickAvatarImage(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) return null;

  final picked = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 85,
  );
  return picked != null ? File(picked.path) : null;
}
