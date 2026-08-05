import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../providers/auth_providers.dart';
import 'auth_button.dart';

/// A one-time, un-skippable gate: shown whenever the signed-in account
/// hasn't recorded `termsAcceptedAt` yet. Catches every brand-new signup
/// (typed form or Google sign-in) right after their role is known, and —
/// since nothing ever set this field for accounts created before this
/// screen existed — every pre-existing account too, the next time they
/// open the app. See the router's redirect guard.
class TermsGateScreen extends ConsumerStatefulWidget {
  const TermsGateScreen({super.key});

  @override
  ConsumerState<TermsGateScreen> createState() => _TermsGateScreenState();
}

class _TermsGateScreenState extends ConsumerState<TermsGateScreen> {
  static const _legalBaseUrl = 'https://collabsy-mobile-applicaation.web.app';

  bool _agreed = false;

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _continue() async {
    await ref.read(authControllerProvider.notifier).acceptTerms();
    if (!mounted) return;
    if (ref.read(authControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't save that. Please try again.");
      return;
    }
    // Routes through splash so the router's redirect guard re-evaluates the
    // full chain (onboarding/verification/home) from scratch, rather than
    // assuming home is next — same pattern used after completeOnboarding().
    context.go(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.gavel_outlined,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text('One more thing', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(
                'Please review and agree to our Privacy Policy and Terms '
                'of Service to continue.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _LegalLink(
                label: 'Privacy Policy',
                onTap: () => _openUrl('$_legalBaseUrl/privacy/'),
              ),
              const SizedBox(height: 8),
              _LegalLink(
                label: 'Terms of Service',
                onTap: () => _openUrl('$_legalBaseUrl/terms/'),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _agreed,
                activeColor: AppColors.primary,
                onChanged: isLoading
                    ? null
                    : (value) => setState(() => _agreed = value ?? false),
                title: const Text(
                  'I have read and agree to the Privacy Policy and Terms '
                  'of Service.',
                ),
              ),
              const SizedBox(height: 8),
              AuthButton(
                text: 'Agree & Continue',
                isLoading: isLoading,
                onPressed: (_agreed && !isLoading) ? _continue : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => ref.read(authRepositoryProvider).signOut(),
                  child: const Text('Sign out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.open_in_new, size: 14, color: AppColors.primary),
        ],
      ),
    );
  }
}
