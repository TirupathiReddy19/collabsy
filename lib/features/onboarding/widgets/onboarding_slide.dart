import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OnboardingSlideData {
  const OnboardingSlideData({
    required this.emoji,
    required this.title,
    required this.description,
  });

  final String emoji;
  final String title;
  final String description;
}

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({super.key, required this.data});

  final OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Text(data.emoji, style: const TextStyle(fontSize: 48)),
        ),
        const SizedBox(height: 40),
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: AppTextStyles.heading1,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            data.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
