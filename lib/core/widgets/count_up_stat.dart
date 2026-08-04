import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A stat number that animates counting up from 0 to [value] on first
/// build — a small "alive" touch for dashboard stat rows.
class CountUpStat extends StatelessWidget {
  const CountUpStat({
    super.key,
    required this.label,
    required this.value,
    this.suffix = '',
    this.color,
  });

  final String label;
  final int value;
  final String suffix;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: value),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) => Text(
            '$animatedValue$suffix',
            style: AppTextStyles.heading2.copyWith(
              color: color ?? AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
