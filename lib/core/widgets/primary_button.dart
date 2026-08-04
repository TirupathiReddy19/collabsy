import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width = double.infinity,
    this.height = 56,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = AppColors.white,
    this.borderRadius = AppRadius.lg,
    this.elevation = 0,
  });

  final String text;
  final VoidCallback? onPressed;

  final bool isLoading;
  final bool isEnabled;

  final IconData? icon;

  final double width;
  final double height;

  final Color backgroundColor;
  final Color foregroundColor;

  final double borderRadius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final bool disabled = !isEnabled || isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: .5),
          disabledForegroundColor: foregroundColor.withValues(alpha: .8),
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                  ),
                )
              : Row(
                  key: const ValueKey('content'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      text,
                      style: AppTextStyles.button.copyWith(
                        color: foregroundColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
