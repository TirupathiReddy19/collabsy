import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../theme/admin_colors.dart';

/// Matches the Figma `StatCard` — icon in a tinted square, big value,
/// label, optional colored trend line. The primary KPI primitive reused
/// across every admin screen.
class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.change,
    this.changeColor,
    this.iconColor,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? change;
  final Color? changeColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AdminColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.micro.copyWith(
              color: AdminColors.textSecondary(context),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          _AnimatedValue(value: value),
          if (change != null) ...[
            const SizedBox(height: 4),
            Text(
              change!,
              style: AppTextStyles.bodySmall.copyWith(
                color: changeColor ?? AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

/// Counts up from the previously-shown value (0 on first build) whenever
/// [value] changes — a small "alive" touch instead of numbers just
/// appearing fully-formed. Non-numeric values (the `—`/`!` loading/error
/// placeholders `AdminDashboardScreen._valueOf` produces) are shown as-is.
class _AnimatedValue extends StatelessWidget {
  const _AnimatedValue({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final parsed = int.tryParse(value);
    if (parsed == null) {
      return Text(
        value,
        style: AppTextStyles.heading1.copyWith(fontWeight: FontWeight.w800),
      );
    }
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: parsed),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) => Text(
        '$animatedValue',
        style: AppTextStyles.heading1.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
