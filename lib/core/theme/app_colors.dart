import 'package:flutter/material.dart';

/// Centralized color palette for the Collabsy application.
///
/// All colors used throughout the app should be defined here.
/// Avoid hardcoding Color(...) values inside widgets.
class AppColors {
  AppColors._();

  // ==========================================================
  // Brand Colors
  // ==========================================================

  static const Color primary = Color(0xFFF97316);
  static const Color primaryDark = Color(0xFFEA580C);
  static const Color primaryLight = Color(0xFFFB923C);

  static const Color secondary = Color(0xFF2563EB);

  // ==========================================================
  // Background
  // ==========================================================

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FAFC);
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

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ==========================================================
  // Border & Divider
  // ==========================================================

  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF1F5F9);

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