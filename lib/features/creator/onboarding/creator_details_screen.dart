import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/campaign_categories.dart';
import '../../../core/utils/india_regions.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/searchable_dropdown_field.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/shared/auth_button.dart';
import '../../auth/shared/auth_header.dart';
import '../models/collaboration_preference.dart';
import '../models/creator_gender.dart';
import 'widgets/gender_collaboration_fields.dart';

/// First of two post-signup steps for Creators (see [AppRoutes.creatorDetails]
/// / [AppRoutes.creatorInstagramConnect]) — collects languages + location,
/// gated before the dashboard via `users/{uid}.onboardingCompleted`.
class CreatorDetailsScreen extends ConsumerStatefulWidget {
  const CreatorDetailsScreen({super.key});

  @override
  ConsumerState<CreatorDetailsScreen> createState() =>
      _CreatorDetailsScreenState();
}

class _CreatorDetailsScreenState extends ConsumerState<CreatorDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');
  final Set<String> _selectedLanguages = {};
  final Set<String> _selectedCategories = {};
  String? _selectedState;
  CreatorGender? _selectedGender;
  CollaborationPreference? _selectedCollabPreference;

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_selectedLanguages.isEmpty) {
      AppSnackbar.showError(context, 'Select at least one language');
      return;
    }
    if (_selectedState == null) {
      AppSnackbar.showError(context, 'Select your state');
      return;
    }
    if (_selectedGender == null) {
      AppSnackbar.showError(context, 'Select your gender');
      return;
    }
    if (_selectedCollabPreference == null) {
      AppSnackbar.showError(
        context,
        "Select what collaborations you're open to",
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authControllerProvider.notifier)
        .saveCreatorDetails(
          languages: _selectedLanguages.toList(),
          categories: _selectedCategories.toList(),
          stateName: _selectedState!,
          city: _cityController.text.trim(),
          gender: _selectedGender!,
          collaborationPreference: _selectedCollabPreference!,
        );
    if (!mounted) return;

    if (ref.read(authControllerProvider).hasError) {
      AppSnackbar.showError(
        context,
        "Couldn't save your details. Please try again.",
      );
      return;
    }

    context.push(AppRoutes.creatorInstagramConnect);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.screenVertical,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(
                  title: 'Tell us about yourself',
                  subtitle: 'Step 1 of 2 — helps brands find creators like you',
                ),
                const SizedBox(height: 24),
                Text('Languages you speak', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: indianLanguages.map((lang) {
                    final selected = _selectedLanguages.contains(lang);
                    return FilterChip(
                      label: Text(lang),
                      selected: selected,
                      onSelected: isLoading
                          ? null
                          : (value) => setState(() {
                              if (value) {
                                _selectedLanguages.add(lang);
                              } else {
                                _selectedLanguages.remove(lang);
                              }
                            }),
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      labelStyle: AppTextStyles.bodySmall.copyWith(
                        color: selected
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                      ),
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text('Your niche', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: campaignCategories.map((category) {
                    final selected = _selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: isLoading
                          ? null
                          : (value) => setState(() {
                              if (value) {
                                _selectedCategories.add(category);
                              } else {
                                _selectedCategories.remove(category);
                              }
                            }),
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      labelStyle: AppTextStyles.bodySmall.copyWith(
                        color: selected
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                      ),
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Country',
                  enabled: false,
                  controller: _countryController,
                ),
                const SizedBox(height: 16),
                SearchableDropdownField(
                  label: 'State',
                  items: indianStates,
                  selected: _selectedState,
                  enabled: !isLoading,
                  onChanged: (value) => setState(() => _selectedState = value),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _cityController,
                  label: 'City',
                  hintText: 'Mumbai',
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter your city'
                      : null,
                  onSubmitted: (_) => _continue(),
                ),
                const SizedBox(height: 24),
                GenderCollaborationFields(
                  selectedGender: _selectedGender,
                  selectedPreference: _selectedCollabPreference,
                  enabled: !isLoading,
                  onGenderChanged: (value) =>
                      setState(() => _selectedGender = value),
                  onPreferenceChanged: (value) =>
                      setState(() => _selectedCollabPreference = value),
                ),
                const SizedBox(height: 24),
                AuthButton(
                  text: 'Continue',
                  onPressed: isLoading ? null : _continue,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
