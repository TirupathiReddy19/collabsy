import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Dark-mode structural colors — used only by [AppTheme.darkTheme] and by
/// `AdminColors` (`lib/admin/theme/admin_colors.dart`). Kept separate from
/// [AppColors] rather than added to it, since [AppColors] is 100%
/// `static const` and referenced in `const` contexts across the mobile app;
/// turning it brightness-aware there would risk breaking those. Brand/status
/// colors (primary, success, error, etc.) are intentionally identical in
/// both themes, so they're not duplicated here.
class AppDarkColors {
  AppDarkColors._();

  static const Color background = Color(0xFF0B0D12);
  static const Color surface = Color(0xFF161920);
  static const Color card = Color(0xFF161920);
  static const Color border = Color(0xFF262B33);
  static const Color divider = Color(0xFF262B33);
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFF6B7280);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.light,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
      ),

      scaffoldBackgroundColor: AppColors.background,

      fontFamily: AppTextStyles.fontFamily,

      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,

        headlineLarge: AppTextStyles.heading1,
        headlineMedium: AppTextStyles.heading2,
        headlineSmall: AppTextStyles.heading3,

        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,

        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,

        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonHorizontal,
            vertical: AppSpacing.buttonVertical,
          ),
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppBorderRadius.lg),
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          shape: const RoundedRectangleBorder(borderRadius: AppBorderRadius.lg),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputHorizontal,
          vertical: AppSpacing.inputVertical,
        ),

        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),

        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.lg,
          borderSide: const BorderSide(color: AppColors.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.lg,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.lg,
          borderSide: const BorderSide(color: AppColors.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.lg,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppBorderRadius.xl),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppBorderRadius.lg),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTextStyles.micro.copyWith(
            color: selected ? AppColors.primary : AppColors.textHint,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.textHint,
          );
        }),
      ),
    );
  }

  /// Admin-portal-only dark theme (see [AppDarkColors]). Not wired into the
  /// mobile app's `MaterialApp`, which sets `theme:` explicitly with no
  /// `darkTheme:`/`themeMode:`, so this has no effect there.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.dark,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppDarkColors.surface,
      ),

      scaffoldBackgroundColor: AppDarkColors.background,

      fontFamily: AppTextStyles.fontFamily,

      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppDarkColors.textPrimary,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: AppDarkColors.textPrimary,
        ),

        headlineLarge: AppTextStyles.heading1.copyWith(
          color: AppDarkColors.textPrimary,
        ),
        headlineMedium: AppTextStyles.heading2.copyWith(
          color: AppDarkColors.textPrimary,
        ),
        headlineSmall: AppTextStyles.heading3.copyWith(
          color: AppDarkColors.textPrimary,
        ),

        titleLarge: AppTextStyles.titleLarge.copyWith(
          color: AppDarkColors.textPrimary,
        ),
        titleMedium: AppTextStyles.titleMedium.copyWith(
          color: AppDarkColors.textPrimary,
        ),
        titleSmall: AppTextStyles.titleSmall.copyWith(
          color: AppDarkColors.textPrimary,
        ),

        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppDarkColors.textPrimary,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppDarkColors.textPrimary,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppDarkColors.textSecondary,
        ),

        labelLarge: AppTextStyles.labelLarge.copyWith(
          color: AppDarkColors.textPrimary,
        ),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: AppDarkColors.textSecondary,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: AppDarkColors.textHint,
        ),
      ),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppDarkColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonHorizontal,
            vertical: AppSpacing.buttonVertical,
          ),
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppBorderRadius.lg),
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          foregroundColor: AppDarkColors.textPrimary,
          side: const BorderSide(color: AppDarkColors.border),
          shape: const RoundedRectangleBorder(borderRadius: AppBorderRadius.lg),
          textStyle: AppTextStyles.button.copyWith(
            color: AppDarkColors.textPrimary,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppDarkColors.surface,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputHorizontal,
          vertical: AppSpacing.inputVertical,
        ),

        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppDarkColors.textHint,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.lg,
          borderSide: const BorderSide(color: AppDarkColors.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.lg,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.lg,
          borderSide: const BorderSide(color: AppColors.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.lg,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppDarkColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppBorderRadius.xl),
      ),

      dividerTheme: const DividerThemeData(
        color: AppDarkColors.divider,
        thickness: 1,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppDarkColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppDarkColors.background,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppBorderRadius.lg),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppDarkColors.surface,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTextStyles.micro.copyWith(
            color: selected ? AppColors.primary : AppDarkColors.textHint,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppDarkColors.textHint,
          );
        }),
      ),
    );
  }
}
