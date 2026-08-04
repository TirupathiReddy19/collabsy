import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A circular avatar showing [avatarUrl] when set, falling back to
/// [fallbackIcon] otherwise. Pass [onEdit] to show a pencil badge that
/// triggers picking/uploading a new photo; [isUploading] swaps the badge
/// for a spinner while that's in flight.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    required this.fallbackIcon,
    this.radius = AppSpacing.avatarLg / 2,
    this.onEdit,
    this.isUploading = false,
  });

  final String? avatarUrl;
  final IconData fallbackIcon;
  final double radius;
  final VoidCallback? onEdit;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primaryLight,
          child: ClipOval(
            child: url == null || url.isEmpty
                ? Icon(fallbackIcon, color: AppColors.primary, size: radius)
                : CachedNetworkImage(
                    imageUrl: url,
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Icon(
                      fallbackIcon,
                      color: AppColors.primary,
                      size: radius,
                    ),
                    errorWidget: (context, url, error) => Icon(
                      fallbackIcon,
                      color: AppColors.primary,
                      size: radius,
                    ),
                  ),
          ),
        ),
        if (isUploading)
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: radius,
                  height: radius,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        else if (onEdit != null)
          Positioned(
            bottom: -2,
            right: -2,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                child: const Icon(Icons.edit, size: 14, color: AppColors.white),
              ),
            ),
          ),
      ],
    );
  }
}
