import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Inline circular loading spinner using the app's brand color.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size = 24,
    this.strokeWidth = 2.5,
    this.color,
  });

  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
      ),
    );
  }
}

/// Wraps [child] with a full-screen dimmed overlay + centered spinner
/// while [isLoading] is true. The child stays mounted underneath so
/// scroll position/form state isn't lost while a request is in flight.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.black.withValues(alpha: 0.15),
              child: const Center(child: LoadingIndicator(size: 32)),
            ),
          ),
      ],
    );
  }
}
