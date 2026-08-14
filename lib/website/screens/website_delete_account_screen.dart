import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../providers/delete_account_request_providers.dart';
import '../widgets/website_section.dart';

/// Doesn't require the app installed — this is the page Play Console's
/// Data Safety form (and Apple's equivalent account-deletion requirement)
/// links to for people who can't or don't want to sign in to request
/// deletion. Already-signed-in users get an immediate deletion from
/// Settings → Danger Zone in the app instead; this form goes through
/// manual staff review before anything is deleted, same as the old
/// `web-legal/delete-account/` page it replaces.
class WebsiteDeleteAccountScreen extends ConsumerStatefulWidget {
  const WebsiteDeleteAccountScreen({super.key});

  @override
  ConsumerState<WebsiteDeleteAccountScreen> createState() =>
      _WebsiteDeleteAccountScreenState();
}

class _WebsiteDeleteAccountScreenState
    extends ConsumerState<WebsiteDeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref
        .read(deleteAccountRequestControllerProvider.notifier)
        .submit(
          identifier: _identifierController.text,
          reason: _reasonController.text,
        );

    if (!mounted) return;
    final state = ref.read(deleteAccountRequestControllerProvider);
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
      deleteAccountRequestControllerProvider.select((s) => s.isLoading),
    );

    return WebsiteSection(
      maxWidth: 640,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Request account deletion', style: AppTextStyles.displayMedium),
          const SizedBox(height: 8),
          Text(
            "You don't need the Collabsy app installed to use this page. "
            "Tell us the email address or phone number on your account, "
            "and we'll delete your account and personal data within 30 "
            'days.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(color: AppColors.border),
            ),
            child: _submitted ? const _SuccessState() : _buildForm(isLoading),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'What happens next: this creates a request our team reviews '
            "manually — we verify it's really your account before "
            'anything is deleted, the same care the in-app flow takes. '
            'Once processed, your profile and personal data are removed '
            'the same way they would be through the in-app deletion. '
            'Questions? Email support@collabsy.online.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Text.rich(
              TextSpan(
                style: AppTextStyles.bodyMedium,
                children: [
                  const TextSpan(
                    text: 'Already have the app? ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(
                    text:
                        "It's faster to delete your account directly "
                        'from ',
                  ),
                  const TextSpan(
                    text: 'Settings → Danger Zone → Delete Account',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(
                    text:
                        ' — that happens immediately, no waiting required. '
                        'Use this form only if you no longer have the app '
                        "installed, or can't sign in.",
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _identifierController,
            label: 'Email or phone number on your account',
            hintText: 'you@example.com or +91 98765 43210',
            textInputAction: TextInputAction.next,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter the email or phone number on your account'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _reasonController,
            label: 'Anything else we should know? (optional)',
            hintText: 'Optional — helps us find your account faster',
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            text: 'Submit Deletion Request',
            isLoading: isLoading,
            onPressed: _submit,
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
            'Request received',
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "We'll process this within 30 days — you'll no longer be able "
            "to sign in once it's done.",
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
