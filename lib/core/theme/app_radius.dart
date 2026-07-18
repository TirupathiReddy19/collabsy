import 'package:flutter/widgets.dart';

/// Centralized border radius values.
///
/// Avoid hardcoding BorderRadius.circular(...)
/// throughout the application.
///
/// Example:
/// BorderRadius.circular(AppRadius.md)
class AppRadius {
  AppRadius._();

  /// Small elements
  static const double xs = 4;

  /// Chips
  static const double sm = 8;

  /// TextFields
  static const double md = 12;

  /// Buttons & Cards
  static const double lg = 16;

  /// Dialogs
  static const double xl = 20;

  /// Splash logo card
  static const double xxl = 24;

  /// Bottom Sheets
  static const double xxxl = 32;

  /// Circular widgets
  static const double full = 999;
}

/// Common BorderRadius values.
///
/// Use these instead of repeatedly writing
/// BorderRadius.circular(...)
class AppBorderRadius {
  AppBorderRadius._();

  static const BorderRadius xs = BorderRadius.all(
    Radius.circular(AppRadius.xs),
  );

  static const BorderRadius sm = BorderRadius.all(
    Radius.circular(AppRadius.sm),
  );

  static const BorderRadius md = BorderRadius.all(
    Radius.circular(AppRadius.md),
  );

  static const BorderRadius lg = BorderRadius.all(
    Radius.circular(AppRadius.lg),
  );

  static const BorderRadius xl = BorderRadius.all(
    Radius.circular(AppRadius.xl),
  );

  static const BorderRadius xxl = BorderRadius.all(
    Radius.circular(AppRadius.xxl),
  );

  static const BorderRadius xxxl = BorderRadius.all(
    Radius.circular(AppRadius.xxxl),
  );

  static const BorderRadius circular = BorderRadius.all(
    Radius.circular(AppRadius.full),
  );
}