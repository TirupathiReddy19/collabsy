import 'package:flutter/material.dart';

/// Centralized color palette for the Collabsy application.
///
/// Values mirror `Figma/Collabsy UI_UX Design System (1)/public/tokens.json`,
/// the authoritative design-token source for this app.
/// Avoid hardcoding Color(...) values inside widgets.
class AppColors {
  AppColors._();

  // ==========================================================
  // Brand Colors
  // ==========================================================

  static const Color primary = Color(0xFFF97316);
  static const Color primaryDark = Color(0xFFC2410C);
  static const Color primaryLight = Color(0xFFFFF1E8);
  static const Color primaryHover = Color(0xFFEA580C);

  static const Color secondary = Color(0xFF2563EB);

  // ==========================================================
  // Background
  // ==========================================================

  static const Color background = Color(0xFFFFFDFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // ==========================================================
  // Text Colors
  // ==========================================================

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // ==========================================================
  // Status Colors
  // ==========================================================

  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);

  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFF3E8FF);

  // ==========================================================
  // Border & Divider
  // ==========================================================

  static const Color border = Color(0xFFF1E6DD);
  static const Color borderInput = Color(0xFFF1E6DD);
  static const Color borderFocus = Color(0xFFF97316);
  static const Color divider = Color(0xFFF1E6DD);

  // ==========================================================
  // Disabled
  // ==========================================================

  static const Color disabled = Color(0xFFD1D5DB);

  // ==========================================================
  // Splash Screen
  // ==========================================================

  static const Color splashBackground = primary;

  static const Color splashGradientLight = Color(0xFFFB923C);
  static const Color splashGradientDark = Color(0xFFEA580C);

  static const Color splashGlass = Color(0x33FFFFFF);
  static const Color splashGlassBorder = Color(0x4DFFFFFF);

  // ==========================================================
  // Social Login
  // ==========================================================

  static const Color google = Color(0xFFDB4437);
  static const Color facebook = Color(0xFF1877F2);
  static const Color apple = Color(0xFF000000);

  // ==========================================================
  // Creator Theme
  // ==========================================================

  static const Color creator = Color(0xFF8B5CF6);

  // ==========================================================
  // Brand Theme
  // ==========================================================

  static const Color brand = Color(0xFF0EA5E9);
}
