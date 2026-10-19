import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../theme/admin_colors.dart';

/// One label/value line inside an admin detail card — icon, label, value.
/// Shared by the Creator/Brand/Campaign detail screens.
class AdminDetailRow extends StatelessWidget {
  const AdminDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  /// When set, the value is shown as a link and the whole row opens it —
  /// e.g. launching a creator's Instagram profile URL.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final valueStyle = onTap == null
        ? AppTextStyles.labelLarge
        : AppTextStyles.labelLarge.copyWith(
            color: AppColors.primary,
            decoration: TextDecoration.underline,
          );
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AdminColors.textSecondary(context)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AdminColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: valueStyle),
            ],
          ),
        ),
      ],
    );
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: onTap == null
          ? row
          : InkWell(onTap: onTap, child: row),
    );
  }
}
