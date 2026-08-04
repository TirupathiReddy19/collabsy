import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

enum _SnackbarVariant { success, error, info, warning }

/// Themed snackbar helpers for the Collabsy application.
///
/// Use these instead of calling `ScaffoldMessenger`/`SnackBar` directly.
class AppSnackbar {
  AppSnackbar._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, _SnackbarVariant.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, _SnackbarVariant.error);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, _SnackbarVariant.info);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, _SnackbarVariant.warning);
  }

  static void _show(
    BuildContext context,
    String message,
    _SnackbarVariant variant,
  ) {
    final (background, foreground, icon) = switch (variant) {
      _SnackbarVariant.success => (
        AppColors.success,
        AppColors.white,
        Icons.check_circle_rounded,
      ),
      _SnackbarVariant.error => (
        AppColors.error,
        AppColors.white,
        Icons.error_rounded,
      ),
      _SnackbarVariant.info => (
        AppColors.textPrimary,
        AppColors.white,
        Icons.info_rounded,
      ),
      _SnackbarVariant.warning => (
        AppColors.warning,
        AppColors.white,
        Icons.warning_rounded,
      ),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          content: Row(
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
