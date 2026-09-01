import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/collaboration_preference.dart';
import '../../models/creator_gender.dart';

/// The gender + collaboration-preference questions, shared verbatim between
/// [CreatorDetailsScreen] (brand-new signups, step 1 of onboarding) and
/// `CreatorAdditionalDetailsScreen` (the one-time gate pre-existing
/// creator accounts are sent through, since these fields didn't exist when
/// they originally onboarded) — same two questions, same look, in both
/// places, so a creator never notices this was bolted on later.
class GenderCollaborationFields extends StatelessWidget {
  const GenderCollaborationFields({
    super.key,
    required this.selectedGender,
    required this.selectedPreference,
    required this.onGenderChanged,
    required this.onPreferenceChanged,
    this.enabled = true,
  });

  final CreatorGender? selectedGender;
  final CollaborationPreference? selectedPreference;
  final ValueChanged<CreatorGender> onGenderChanged;
  final ValueChanged<CollaborationPreference> onPreferenceChanged;
  final bool enabled;

  Widget _chipRow<T>({
    required List<T> values,
    required T? selected,
    required String Function(T) labelOf,
    required ValueChanged<T> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) {
        final isSelected = value == selected;
        return ChoiceChip(
          label: Text(labelOf(value)),
          selected: isSelected,
          onSelected: enabled ? (_) => onSelected(value) : null,
          selectedColor: AppColors.primaryLight,
          checkmarkColor: AppColors.primary,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
          ),
          backgroundColor: AppColors.surface,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        _chipRow<CreatorGender>(
          values: CreatorGender.values,
          selected: selectedGender,
          labelOf: (g) => g.label,
          onSelected: onGenderChanged,
        ),
        const SizedBox(height: 24),
        Text('Collaborations you\'re open to', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        _chipRow<CollaborationPreference>(
          values: CollaborationPreference.values,
          selected: selectedPreference,
          labelOf: (p) => p.label,
          onSelected: onPreferenceChanged,
        ),
      ],
    );
  }
}
