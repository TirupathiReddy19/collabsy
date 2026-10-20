import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized typography for the Collabsy application.
///
/// Sizes mirror the `typography.scale` in
/// `Figma/Collabsy UI_UX Design System (1)/public/tokens.json`
/// (display/h1/h2/h3/body/caption/micro), rendered in Inter per the
/// token file's `typography.fontFamily`.
///
/// Inter ships as a local asset (`assets/fonts/Inter-Variable.ttf`), not
/// via `google_fonts`' runtime fetch — on Flutter Web, text that renders
/// before a runtime-fetched font finishes downloading gets laid out with
/// wrong/zero glyph widths, which showed up as every character wrapping
/// onto its own line (confirmed live on the admin Deletion Requests
/// screen, reproducible on every refresh). Bundling the font removes the
/// race entirely instead of working around it.
///
/// Avoid creating TextStyle(...) directly inside widgets.
/// Always use AppTextStyles.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  // ==========================================================
  // Display — tokens.scale.display (36/44, w900)
  // ==========================================================

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    height: 44 / 36,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // ==========================================================
  // Headings — tokens.scale.h1/h2/h3
  // ==========================================================

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ==========================================================
  // Titles
  // ==========================================================

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ==========================================================
  // Body — tokens.scale.body (14/20, w400) & caption (12/16, w500)
  // ==========================================================

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// tokens.scale.micro (10/14, w500)
  static const TextStyle micro = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );

  // ==========================================================
  // Buttons
  // ==========================================================

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // ==========================================================
  // Labels
  // ==========================================================

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );

  // ==========================================================
  // Links
  // ==========================================================

  static const TextStyle link = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // ==========================================================
  // Splash
  // ==========================================================

  static const TextStyle splashTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    height: 44 / 36,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: -1,
  );

  static final TextStyle splashSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white.withValues(alpha: 0.85),
  );
}
