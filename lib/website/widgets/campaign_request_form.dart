import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../providers/campaign_request_providers.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// The Brands page's "let us run it for you" lead form — submits straight
/// to Firestore via [CampaignRequestController], no email confirmation
/// loop, just an in-page success state.
class CampaignRequestForm extends ConsumerStatefulWidget {
  const CampaignRequestForm({super.key});

  @override
  ConsumerState<CampaignRequestForm> createState() =>
      _CampaignRequestFormState();
}

class _CampaignRequestFormState extends ConsumerState<CampaignRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _briefController = TextEditingController();
  CampaignBudgetRange _budgetRange = CampaignBudgetRange.notSure;
  bool _submitted = false;

  @override
  void dispose() {
    _companyController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _briefController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref
        .read(campaignRequestControllerProvider.notifier)
        .submit(
          companyName: _companyController.text,
          contactName: _contactController.text,
          workEmail: _emailController.text,
          phone: _phoneController.text,
          budgetRange: _budgetRange,
          campaignBrief: _briefController.text,
        );

    if (!mounted) return;
    final state = ref.read(campaignRequestControllerProvider);
    if (state.hasError) {
      AppSnackbar.showError(
        context,
        "Couldn't send your request. Please try again.",
      );
      return;
    }
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      campaignRequestControllerProvider.select((s) => s.isLoading),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
      ),
      child: _submitted ? const _SuccessState() : _buildForm(isLoading),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Get a free campaign plan', style: AppTextStyles.heading1),
          const SizedBox(height: 6),
          Text(
            'Tell us about your brand — our team runs the campaign end to '
            "end, you just review the results.",
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _companyController,
            label: 'Company name',
            hintText: 'e.g. Acme Skincare',
            textInputAction: TextInputAction.next,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter your company name'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _contactController,
            label: 'Your name',
            hintText: 'e.g. Priya Sharma',
            textInputAction: TextInputAction.next,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter your name'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _emailController,
            label: 'Work email',
            hintText: 'you@company.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your work email';
              }
              if (!_emailPattern.hasMatch(value.trim())) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _phoneController,
            label: 'Phone (optional)',
            hintText: '+91 98765 43210',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Monthly campaign budget', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<CampaignBudgetRange>(
            initialValue: _budgetRange,
            items: CampaignBudgetRange.values
                .map(
                  (range) =>
                      DropdownMenuItem(value: range, child: Text(range.label)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _budgetRange = value);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _briefController,
            label: 'What are you looking to achieve?',
            hintText: 'Tell us about your brand, product, and campaign goals',
            maxLines: 4,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Tell us a bit about your campaign'
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            text: 'Get Free Campaign Plan',
            isLoading: isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No commitment. Get your free campaign strategy before you '
            'spend a single rupee.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "Thanks — we've got it",
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Our team will reach out on your work email or WhatsApp within "
            "1 business day with your free campaign plan.",
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
