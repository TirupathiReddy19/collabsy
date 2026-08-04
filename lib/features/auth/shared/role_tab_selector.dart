import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/user_role.dart';

/// Creator / Brand segmented control shown on the signup screen — this
/// choice becomes the account's [UserRole], written once at signup.
class RoleTabSelector extends StatelessWidget {
  const RoleTabSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(child: _tab(UserRole.creator, 'Creator')),
          Expanded(child: _tab(UserRole.brand, 'Brand / Agency')),
        ],
      ),
    );
  }

  Widget _tab(UserRole role, String label) {
    final isSelected = role == selected;

    return GestureDetector(
      onTap: () => onChanged(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.titleSmall.copyWith(
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
