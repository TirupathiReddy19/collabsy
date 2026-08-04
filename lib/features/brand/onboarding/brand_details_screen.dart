import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/campaign_categories.dart';
import '../../../core/utils/company_size_options.dart';
import '../../../core/utils/india_regions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/searchable_dropdown_field.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/brand_profile_providers.dart';

/// 3-step post-signup onboarding wizard for Brands — collects the company
/// details Brands don't provide at signup (company name, designation,
/// industry, size, website, LinkedIn, location). Gated before the
/// dashboard via `users/{uid}.onboardingCompleted`, same mechanism as
/// Creator onboarding — accounts created before this step existed default
/// to `onboardingCompleted: false`, so they're routed here automatically.
class BrandDetailsScreen extends ConsumerStatefulWidget {
  const BrandDetailsScreen({super.key});

  @override
  ConsumerState<BrandDetailsScreen> createState() => _BrandDetailsScreenState();
}

class _BrandDetailsScreenState extends ConsumerState<BrandDetailsScreen> {
  final _aboutFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _designationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _cityController = TextEditingController();
  final Set<String> _selectedCategories = {};
  String? _companySize;
  String? _selectedState;

  int _step = 0;

  @override
  void dispose() {
    _companyNameController.dispose();
    _designationController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _continueFromAbout() {
    if (!_aboutFormKey.currentState!.validate()) return;
    setState(() => _step = 1);
  }

  void _continueFromIndustry() {
    if (_selectedCategories.isEmpty) {
      AppSnackbar.showError(context, 'Select at least one industry');
      return;
    }
    if (_companySize == null) {
      AppSnackbar.showError(context, 'Select your company size');
      return;
    }
    setState(() => _step = 2);
  }

  Future<void> _finish() async {
    if (!_contactFormKey.currentState!.validate()) return;
    if (_selectedState == null) {
      AppSnackbar.showError(context, 'Select your state');
      return;
    }

    await ref
        .read(brandProfileControllerProvider.notifier)
        .updateProfile(
          companyName: _companyNameController.text.trim(),
          designation: _designationController.text.trim(),
          categories: _selectedCategories.toList(),
          companySize: _companySize,
          website: _websiteController.text.trim(),
          linkedinUrl: _linkedinController.text.trim(),
          stateName: _selectedState,
          city: _cityController.text.trim(),
        );
    if (!mounted) return;
    if (ref.read(brandProfileControllerProvider).hasError) {
      AppSnackbar.showError(
        context,
        "Couldn't save your details. Please try again.",
      );
      return;
    }

    await ref.read(authControllerProvider.notifier).completeOnboarding();
    if (!mounted) return;
    if (ref.read(authControllerProvider).hasError) {
      AppSnackbar.showError(
        context,
        "Couldn't finish setup. Please try again.",
      );
      return;
    }
    context.go(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(brandProfileControllerProvider).isLoading ||
        ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text('About your brand — Step ${_step + 1} of 3'),
        automaticallyImplyLeading: false,
        leading: _step == 0
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step -= 1),
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: switch (_step) {
            0 => _AboutStep(
              formKey: _aboutFormKey,
              companyNameController: _companyNameController,
              designationController: _designationController,
              isLoading: isLoading,
              onContinue: _continueFromAbout,
            ),
            1 => _IndustryStep(
              categories: _selectedCategories,
              companySize: _companySize,
              isLoading: isLoading,
              onCategoryToggled: (value) => setState(
                () => _selectedCategories.contains(value)
                    ? _selectedCategories.remove(value)
                    : _selectedCategories.add(value),
              ),
              onSizeChanged: (value) => setState(() => _companySize = value),
              onContinue: _continueFromIndustry,
            ),
            _ => _ContactStep(
              formKey: _contactFormKey,
              websiteController: _websiteController,
              linkedinController: _linkedinController,
              cityController: _cityController,
              selectedState: _selectedState,
              isLoading: isLoading,
              onStateChanged: (value) => setState(() => _selectedState = value),
              onFinish: _finish,
            ),
          },
        ),
      ),
    );
  }
}

class _AboutStep extends StatelessWidget {
  const _AboutStep({
    required this.formKey,
    required this.companyNameController,
    required this.designationController,
    required this.isLoading,
    required this.onContinue,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController companyNameController;
  final TextEditingController designationController;
  final bool isLoading;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about your brand', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            'Helps creators know who they might work with',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: companyNameController,
            label: 'Company name',
            hintText: 'Nykaa',
            enabled: !isLoading,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter your company name'
                : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: designationController,
            label: 'Your designation',
            hintText: 'e.g. Marketing Manager',
            enabled: !isLoading,
            textInputAction: TextInputAction.done,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter your designation'
                : null,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Continue',
            onPressed: isLoading ? null : onContinue,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

class _IndustryStep extends StatelessWidget {
  const _IndustryStep({
    required this.categories,
    required this.companySize,
    required this.isLoading,
    required this.onCategoryToggled,
    required this.onSizeChanged,
    required this.onContinue,
  });

  final Set<String> categories;
  final String? companySize;
  final bool isLoading;
  final ValueChanged<String> onCategoryToggled;
  final ValueChanged<String> onSizeChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Industry', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: campaignCategories.map((category) {
            final selected = categories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: selected,
              onSelected: isLoading ? null : (_) => onCategoryToggled(category),
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
        Text('Company size', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: companySizeOptions.map((size) {
            final selected = companySize == size;
            return ChoiceChip(
              label: Text(size),
              selected: selected,
              onSelected: isLoading ? null : (_) => onSizeChanged(size),
              selectedColor: AppColors.primaryLight,
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
        PrimaryButton(
          text: 'Continue',
          onPressed: isLoading ? null : onContinue,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class _ContactStep extends StatelessWidget {
  const _ContactStep({
    required this.formKey,
    required this.websiteController,
    required this.linkedinController,
    required this.cityController,
    required this.selectedState,
    required this.isLoading,
    required this.onStateChanged,
    required this.onFinish,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController websiteController;
  final TextEditingController linkedinController;
  final TextEditingController cityController;
  final String? selectedState;
  final bool isLoading;
  final ValueChanged<String?> onStateChanged;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact & location', style: AppTextStyles.heading2),
          const SizedBox(height: 24),
          AppTextField(
            controller: websiteController,
            label: 'Company website',
            hintText: 'https://yourbrand.com',
            keyboardType: TextInputType.url,
            enabled: !isLoading,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter your company website'
                : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: linkedinController,
            label: 'LinkedIn profile',
            hintText: 'https://linkedin.com/in/you',
            keyboardType: TextInputType.url,
            enabled: !isLoading,
            validator: Validators.linkedinUrl,
          ),
          const SizedBox(height: 16),
          SearchableDropdownField(
            label: 'State',
            items: indianStates,
            selected: selectedState,
            enabled: !isLoading,
            onChanged: onStateChanged,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: cityController,
            label: 'City',
            hintText: 'Mumbai',
            textInputAction: TextInputAction.done,
            enabled: !isLoading,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter your city'
                : null,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Finish',
            onPressed: isLoading ? null : onFinish,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
