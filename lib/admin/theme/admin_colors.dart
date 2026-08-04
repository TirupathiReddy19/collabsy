import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Context-based resolver for the "structural" colors that flip between
/// light/dark in the admin portal — brand/status colors (primary, success,
/// error, info, purple, ...) are intentionally identical in both themes and
/// stay as direct [AppColors] references at call sites. [AppColors] itself
/// is left untouched (see [AppDarkColors]'s doc comment for why).
class AdminColors {
  AdminColors._();

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surface(BuildContext context) =>
      isDark(context) ? AppDarkColors.surface : AppColors.surface;

  static Color background(BuildContext context) =>
      isDark(context) ? AppDarkColors.background : AppColors.background;

  static Color border(BuildContext context) =>
      isDark(context) ? AppDarkColors.border : AppColors.border;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? AppDarkColors.textPrimary : AppColors.textPrimary;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? AppDarkColors.textSecondary : AppColors.textSecondary;

  static Color textHint(BuildContext context) =>
      isDark(context) ? AppDarkColors.textHint : AppColors.textHint;

  static Color card(BuildContext context) =>
      isDark(context) ? AppDarkColors.card : AppColors.card;

  static Color divider(BuildContext context) =>
      isDark(context) ? AppDarkColors.divider : AppColors.divider;
}
