import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized typography for the Collabsy application.
///
/// Sizes mirror the `typography.scale` in
/// `Figma/Collabsy UI_UX Design System (1)/public/tokens.json`
/// (display/h1/h2/h3/body/caption/micro), rendered in Inter per the
/// token file's `typography.fontFamily`.
///
/// Avoid creating TextStyle(...) directly inside widgets.
/// Always use AppTextStyles.
class AppTextStyles {
  AppTextStyles._();

  static final String fontFamily = GoogleFonts.inter().fontFamily!;

  // ==========================================================
  // Display — tokens.scale.display (36/44, w900)
  // ==========================================================

  static final TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 36,
    height: 44 / 36,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -1,
  );

  static final TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // ==========================================================
  // Headings — tokens.scale.h1/h2/h3
  // ==========================================================

  static final TextStyle heading1 = GoogleFonts.inter(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final TextStyle heading2 = GoogleFonts.inter(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final TextStyle heading3 = GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ==========================================================
  // Titles
  // ==========================================================

  static final TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ==========================================================
  // Body — tokens.scale.body (14/20, w400) & caption (12/16, w500)
  // ==========================================================

  static final TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static final TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// tokens.scale.micro (10/14, w500)
  static final TextStyle micro = GoogleFonts.inter(
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );

  // ==========================================================
  // Buttons
  // ==========================================================

  static final TextStyle button = GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // ==========================================================
  // Labels
  // ==========================================================

  static final TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static final TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static final TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );

  // ==========================================================
  // Links
  // ==========================================================

  static final TextStyle link = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // ==========================================================
  // Splash
  // ==========================================================

  static final TextStyle splashTitle = GoogleFonts.inter(
    fontSize: 36,
    height: 44 / 36,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: -1,
  );

  static final TextStyle splashSubtitle = GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white.withValues(alpha: 0.85),
  );
}
