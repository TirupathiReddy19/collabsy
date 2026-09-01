import 'package:flutter/foundation.dart';
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
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/searchable_dropdown_field.dart';
import '../../../core/widgets/staggered_fade_in.dart';
import '../../../shared/utils/creator_display_name.dart';
import '../../../shared/widgets/multi_select_picker_screen.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/shared/change_email_sheet.dart';
import '../../auth/shared/change_phone_sheet.dart';
import '../../settings/providers/instagram_providers.dart';
import '../models/collaboration_preference.dart';
import '../models/creator_gender.dart';
import '../models/creator_profile.dart';
import '../onboarding/widgets/gender_collaboration_fields.dart';
import '../providers/creator_profile_providers.dart';

class CreatorProfileScreen extends ConsumerStatefulWidget {
  const CreatorProfileScreen({super.key});

  @override
  ConsumerState<CreatorProfileScreen> createState() =>
      _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends ConsumerState<CreatorProfileScreen> {
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedLanguages = {};
  String? _selectedState;
  CreatorGender? _selectedGender;
  CollaborationPreference? _selectedCollabPreference;
  bool _initialized = false;
  bool _isEditingBio = false;
  bool _isEditingLocation = false;
  bool _isEditingPreferences = false;

  String _savedBio = '';
  Set<String> _savedCategories = {};
  Set<String> _savedLanguages = {};
  String? _savedState;
  String _savedCity = '';
  CreatorGender? _savedGender;
  CollaborationPreference? _savedCollabPreference;

  @override
  void initState() {
    super.initState();
    _bioController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _bioController.removeListener(_onFieldChanged);
    _cityController.removeListener(_onFieldChanged);
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  /// Rebuilds so the Save button's visibility (driven by [_isDirty])
  /// reflects every keystroke, not just category/language edits.
  void _onFieldChanged() => setState(() {});

  bool get _hasLocation =>
      _cityController.text.isNotEmpty || _selectedState != null;

  bool get _isDirty {
    return _bioController.text.trim() != _savedBio ||
        !setEquals(_selectedCategories, _savedCategories) ||
        !setEquals(_selectedLanguages, _savedLanguages) ||
        _selectedState != _savedState ||
        _cityController.text.trim() != _savedCity ||
        _selectedGender != _savedGender ||
        _selectedCollabPreference != _savedCollabPreference;
  }

  void _initializeFromProfile(CreatorProfile? profile) {
    if (_initialized || profile == null) return;
    _initialized = true;
    _savedBio = profile.bio ?? '';
    _savedCategories = Set.of(profile.categories);
    _savedLanguages = Set.of(profile.languages);
    _savedState = profile.state;
    _savedCity = profile.city ?? '';
    _savedGender = profile.gender;
    _savedCollabPreference = profile.collaborationPreference;
    _bioController.text = _savedBio;
    _cityController.text = _savedCity;
    _selectedCategories.addAll(_savedCategories);
    _selectedLanguages.addAll(_savedLanguages);
    _selectedState = _savedState;
    _selectedGender = _savedGender;
    _selectedCollabPreference = _savedCollabPreference;
  }

  Future<void> _save() async {
    await ref
        .read(creatorProfileControllerProvider.notifier)
        .updateProfile(
          bio: _bioController.text.trim(),
          categories: _selectedCategories.toList(),
          languages: _selectedLanguages.toList(),
          stateName: _selectedState,
          city: _cityController.text.trim(),
          gender: _selectedGender,
          collaborationPreference: _selectedCollabPreference,
        );
    if (!mounted) return;
    if (ref.read(creatorProfileControllerProvider).hasError) {
      AppSnackbar.showError(
        context,
        "Couldn't save your profile. Please try again.",
      );
      return;
    }
    setState(() {
      _savedBio = _bioController.text.trim();
      _savedCategories = Set.of(_selectedCategories);
      _savedLanguages = Set.of(_selectedLanguages);
      _savedState = _selectedState;
      _savedCity = _cityController.text.trim();
      _savedGender = _selectedGender;
      _savedCollabPreference = _selectedCollabPreference;
      _isEditingBio = false;
      _isEditingLocation = false;
      _isEditingPreferences = false;
    });
    AppSnackbar.showSuccess(context, 'Profile updated.');
  }

  Future<void> _editCategories() async {
    final result = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (context) => MultiSelectPickerScreen(
          title: 'Niche',
          options: campaignCategories,
          initialSelected: _selectedCategories,
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      _selectedCategories
        ..clear()
        ..addAll(result);
    });
  }

  Future<void> _editLanguages() async {
    final result = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (context) => MultiSelectPickerScreen(
          title: 'Languages',
          options: indianLanguages,
          initialSelected: _selectedLanguages,
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      _selectedLanguages
        ..clear()
        ..addAll(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final creatorProfileAsync = ref.watch(ownCreatorProfileProvider);
    final instagramAccount = ref.watch(ownInstagramAccountProvider).value;
    final isLoading = ref.watch(creatorProfileControllerProvider).isLoading;

    creatorProfileAsync.whenData(_initializeFromProfile);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaggeredFadeIn(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileAvatar(
                      avatarUrl: instagramAccount?.profilePictureUrl,
                      fallbackIcon: Icons.person,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    profile.when(
                      data: (value) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            creatorDisplayName(
                              value?.displayName,
                              instagramAccount,
                            ),
                            style: AppTextStyles.heading2,
                          ),
                          if (value?.email != null) ...[
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () async {
                                final changed = await ChangeEmailSheet.show(
                                  context,
                                );
                                if (changed == true) {
                                  ref.invalidate(currentProfileProvider);
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    value!.email!,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.edit_outlined,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (value?.phone != null) ...[
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () async {
                                final changed = await ChangePhoneSheet.show(
                                  context,
                                );
                                if (changed == true) {
                                  ref.invalidate(currentProfileProvider);
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    value!.phone!,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.edit_outlined,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      loading: () => const LoadingIndicator(size: 20),
                      error: (error, stackTrace) => Text(
                        'Could not load your profile',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              StaggeredFadeIn(
                delay: const Duration(milliseconds: 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text('Bio', style: AppTextStyles.labelLarge),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: isLoading
                              ? null
                              : () => setState(
                                  () => _isEditingBio = !_isEditingBio,
                                ),
                        ),
                      ],
                    ),
                    if (_isEditingBio)
                      AppTextField(
                        controller: _bioController,
                        hintText: 'Tell brands a bit about yourself',
                        maxLines: 4,
                        enabled: !isLoading,
                      )
                    else
                      Text(
                        _bioController.text.isEmpty
                            ? 'Tell brands a bit about yourself'
                            : _bioController.text,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _bioController.text.isEmpty
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                  ],
                ),
              ),
              StaggeredFadeIn(
                delay: const Duration(milliseconds: 180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Location', style: AppTextStyles.labelLarge),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: isLoading
                              ? null
                              : () => setState(
                                  () =>
                                      _isEditingLocation = !_isEditingLocation,
                                ),
                        ),
                      ],
                    ),
                    if (_isEditingLocation) ...[
                      SearchableDropdownField(
                        label: 'State',
                        items: indianStates,
                        selected: _selectedState,
                        enabled: !isLoading,
                        onChanged: (value) =>
                            setState(() => _selectedState = value),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _cityController,
                        label: 'City',
                        hintText: 'Mumbai',
                        enabled: !isLoading,
                      ),
                    ] else
                      Text(
                        _hasLocation
                            ? [_cityController.text, _selectedState]
                                  .where(
                                    (value) =>
                                        value != null && value.isNotEmpty,
                                  )
                                  .join(', ')
                            : 'Add your city and state',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _hasLocation
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              StaggeredFadeIn(
                delay: const Duration(milliseconds: 270),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Niche', style: AppTextStyles.labelLarge),
                        const Spacer(),
                        TextButton(
                          onPressed: isLoading ? null : _editCategories,
                          child: Text(
                            _selectedCategories.isEmpty ? 'Select' : 'Edit',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedCategories.isEmpty)
                      Text(
                        'No niche selected yet',
                        style: AppTextStyles.bodySmall,
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedCategories.map((category) {
                          return Chip(
                            label: Text(category),
                            onDeleted: isLoading
                                ? null
                                : () => setState(
                                    () => _selectedCategories.remove(category),
                                  ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              StaggeredFadeIn(
                delay: const Duration(milliseconds: 360),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Languages', style: AppTextStyles.labelLarge),
                        const Spacer(),
                        TextButton(
                          onPressed: isLoading ? null : _editLanguages,
                          child: Text(
                            _selectedLanguages.isEmpty ? 'Select' : 'Edit',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedLanguages.isEmpty)
                      Text(
                        'No languages selected yet',
                        style: AppTextStyles.bodySmall,
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedLanguages.map((language) {
                          return Chip(
                            label: Text(language),
                            onDeleted: isLoading
                                ? null
                                : () => setState(
                                    () => _selectedLanguages.remove(language),
                                  ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              StaggeredFadeIn(
                delay: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Preferences', style: AppTextStyles.labelLarge),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: isLoading
                              ? null
                              : () => setState(
                                  () => _isEditingPreferences =
                                      !_isEditingPreferences,
                                ),
                        ),
                      ],
                    ),
                    if (_isEditingPreferences)
                      GenderCollaborationFields(
                        selectedGender: _selectedGender,
                        selectedPreference: _selectedCollabPreference,
                        enabled: !isLoading,
                        onGenderChanged: (value) =>
                            setState(() => _selectedGender = value),
                        onPreferenceChanged: (value) =>
                            setState(() => _selectedCollabPreference = value),
                      )
                    else
                      Builder(
                        builder: (context) {
                          final parts = [
                            _selectedGender?.label,
                            _selectedCollabPreference?.label,
                          ].whereType<String>().toList();
                          return Text(
                            parts.isEmpty ? 'Not set' : parts.join(' · '),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: parts.isEmpty
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          );
                        },
                      ),
                    if (_isDirty) ...[
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Save changes',
                        onPressed: isLoading ? null : _save,
                        isLoading: isLoading,
                      ),
                    ],
                  ],
                ),
              ),
              StaggeredFadeIn(
                delay: const Duration(milliseconds: 450),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text('Settings'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(AppRoutes.settings),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'Sign out',
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textPrimary,
                      borderColor: AppColors.border,
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).signOut(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
