import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';

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

/// Either a newly picked [file], a request to remove the existing photo
/// ([AvatarPickResult.remove]), or (via a plain `null` from
/// [pickOrRemoveAvatarImage]) the user backing out without choosing
/// anything.
sealed class AvatarPickResult {
  const AvatarPickResult();

  const factory AvatarPickResult.file(File file) = AvatarPickResultFile;
  const factory AvatarPickResult.remove() = AvatarPickResultRemove;
}

class AvatarPickResultFile extends AvatarPickResult {
  const AvatarPickResultFile(this.file);
  final File file;
}

class AvatarPickResultRemove extends AvatarPickResult {
  const AvatarPickResultRemove();
}

/// Same "Camera / Gallery" action sheet as [pickAvatarImage], with a third
/// "Remove photo" option shown whenever [hasExistingPhoto] is true — for
/// profile-avatar editors specifically, as opposed to [pickAvatarImage]'s
/// other use (e.g. a one-off chat attachment), where "remove" has no
/// meaning since there's no existing photo to remove.
Future<AvatarPickResult?> pickOrRemoveAvatarImage(
  BuildContext context, {
  required bool hasExistingPhoto,
}) async {
  final choice = await showModalBottomSheet<Object>(
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
          if (hasExistingPhoto)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Remove photo',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () =>
                  Navigator.of(context).pop(const AvatarPickResult.remove()),
            ),
        ],
      ),
    ),
  );
  if (choice == null) return null;
  if (choice is AvatarPickResultRemove) return choice;

  final picked = await ImagePicker().pickImage(
    source: choice as ImageSource,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 85,
  );
  return picked != null ? AvatarPickResult.file(File(picked.path)) : null;
}
