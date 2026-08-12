import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/loading_indicator.dart';

/// Outlined "Continue with Google" button.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: isLoading
            ? const LoadingIndicator(size: 20)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _GoogleMark(),
                  const SizedBox(width: 12),
                  Text(label, style: AppTextStyles.titleSmall),
                ],
              ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    // The real, current four-color Google "G" — the mark Google itself
    // distributes for third-party "Sign in with Google" buttons — rather
    // than a plain letter on a solid circle.
    return SvgPicture.asset(
      'assets/icons/google_logo.svg',
      width: 20,
      height: 20,
    );
  }
}

/// Outlined "Continue with Apple" button — same shape as [SocialButton] so
/// the two sit consistently in a row, iOS-only per Apple's Guideline 4.8
/// (an equivalent option wherever a third-party social login is offered).
class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: isLoading
            ? const LoadingIndicator(size: 20)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _AppleMark(),
                  const SizedBox(width: 12),
                  Text('Continue with Apple', style: AppTextStyles.titleSmall),
                ],
              ),
      ),
    );
  }
}

class _AppleMark extends StatelessWidget {
  const _AppleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.textPrimary,
        shape: BoxShape.circle,
      ),
      child: const FaIcon(
        FontAwesomeIcons.apple,
        color: AppColors.white,
        size: 12,
      ),
    );
  }
}
