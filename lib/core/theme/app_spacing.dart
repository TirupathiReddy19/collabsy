import 'package:flutter/widgets.dart';

/// Centralized spacing values for the entire application.
///
/// Use these constants instead of hardcoded values.
///
/// Example:
/// Padding(
///   padding: const EdgeInsets.all(AppSpacing.lg),
/// )
///
/// SizedBox(height: AppSpacing.md)
class AppSpacing {
  AppSpacing._();

  // Base spacing unit
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double xxxl = 48;

  // Screen padding
  static const double screenHorizontal = 24;
  static const double screenVertical = 24;

  // Card padding
  static const double card = 16;

  // Button padding
  static const double buttonHorizontal = 20;
  static const double buttonVertical = 16;

  // TextField padding
  static const double inputHorizontal = 16;
  static const double inputVertical = 16;

  // Icon spacing
  static const double icon = 12;

  // Avatar sizes
  static const double avatarSm = 32;
  static const double avatarMd = 48;
  static const double avatarLg = 64;
  static const double avatarXl = 96;
}

/// Frequently used EdgeInsets.
///
/// This helps keep widgets clean and consistent.
class AppPadding {
  AppPadding._();

  static const EdgeInsets screen = EdgeInsets.symmetric(
    horizontal: AppSpacing.screenHorizontal,
    vertical: AppSpacing.screenVertical,
  );

  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: AppSpacing.screenHorizontal,
  );

  static const EdgeInsets card = EdgeInsets.all(
    AppSpacing.card,
  );

  static const EdgeInsets input = EdgeInsets.symmetric(
    horizontal: AppSpacing.inputHorizontal,
    vertical: AppSpacing.inputVertical,
  );

  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: AppSpacing.buttonHorizontal,
    vertical: AppSpacing.buttonVertical,
  );
}