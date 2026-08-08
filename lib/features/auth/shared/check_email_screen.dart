import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../providers/auth_providers.dart';
import 'auth_header.dart';

/// Shown right after signup emails a verification link. Firebase's link
/// opens in a browser rather than deep-linking back into the app, so this
/// screen doesn't wait passively — the user taps "I've verified" once
/// they're done and this polls Firebase for the up-to-date status.
///
/// Two distinct paths land here, told apart by
/// [LocalStorageService.pendingPhoneEmailVerification]:
/// - Password signup: the router's own redirect guard lands here on its
///   own, so the email is read off the signed-in user (`currentUser.email`
///   is already set — Firebase sets it at account creation, verified or
///   not).
/// - A phone-first account adding an email (see
///   `CompleteProfileScreen._alreadyVerifiedPhone`): this uses
///   `verifyBeforeUpdateEmail`, which deliberately leaves
///   `currentUser.email` null until the link is actually clicked — so the
///   email to display/resend comes from the local cache instead, and role
///   assignment already happened, so verifying here goes straight to
///   splash rather than back through complete-profile.
class CheckEmailScreen extends ConsumerWidget {
  const CheckEmailScreen({super.key});

  Future<void> _resend(BuildContext context, WidgetRef ref) async {
    final pendingPhoneEmail = ref
        .read(localStorageServiceProvider)
        .pendingPhoneEmailVerification;
    if (pendingPhoneEmail != null) {
      await ref
          .read(authControllerProvider.notifier)
          .verifyBeforeUpdateEmail(pendingPhoneEmail);
    } else {
      await ref
          .read(authControllerProvider.notifier)
          .resendEmailVerification();
    }
    if (!context.mounted) return;
    if (ref.read(authControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't resend. Please try again.");
    } else {
      AppSnackbar.showSuccess(context, 'Email sent again.');
    }
  }

  Future<void> _checkVerified(BuildContext context, WidgetRef ref) async {
    final verified = await ref
        .read(authControllerProvider.notifier)
        .checkEmailVerified();
    if (!context.mounted) return;

    if (ref.read(authControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't check status. Try again.");
      return;
    }

    if (!verified) {
      AppSnackbar.showError(
        context,
        "Not verified yet — tap the link in the email first.",
      );
      return;
    }

    final localStorage = ref.read(localStorageServiceProvider);
    if (localStorage.pendingPhoneEmailVerification != null) {
      await localStorage.clearPendingPhoneEmailVerification();
      if (!context.mounted) return;
      context.go(AppRoutes.splash);
      return;
    }

    context.go(AppRoutes.completeProfile);
  }

  /// "Back to login" while signed in with an unverified email/password
  /// account isn't just a navigation — the router's redirect guard would
  /// otherwise bounce any such session straight back to this screen. This
  /// is the escape hatch for a typo'd email: abandon the pending account
  /// by signing out first, which the guard then lets through.
  Future<void> _backToLogin(BuildContext context, WidgetRef ref) async {
    // Also clears the phone-first pending-email cache, if set — otherwise
    // logging back in with this now-registered phone would hit the
    // router's gate and land right back here with the same typo'd email
    // and no way to fix it.
    await ref
        .read(localStorageServiceProvider)
        .clearPendingPhoneEmailVerification();
    await ref.read(authControllerProvider.notifier).signOut();
    if (!context.mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final email =
        ref.watch(localStorageServiceProvider).pendingPhoneEmailVerification ??
        ref.watch(authRepositoryProvider).currentUser?.email ??
        '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.screenVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(
                title: 'Check your email',
                subtitle:
                    "We sent a link to $email — tap it to finish "
                    "creating your account, then come back here.",
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: isLoading
                    ? null
                    : () => _checkVerified(context, ref),
                child: Text(
                  isLoading ? 'Checking...' : "I've verified — continue",
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Didn't get it? Check spam, or resend below.",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: isLoading ? null : () => _resend(context, ref),
                child: Text('Resend email', style: AppTextStyles.link),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () => _backToLogin(context, ref),
                  child: const Text('Back to login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
