import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/instagram_icon.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/shared/auth_button.dart';
import '../../auth/shared/auth_header.dart';
import '../../settings/data/instagram_repository.dart';
import '../../settings/providers/instagram_providers.dart';
import '../../settings/widgets/instagram_oauth_webview_screen.dart';

/// Second of two post-signup steps for Creators. Connecting here runs the
/// same Instagram Business Login flow as Settings -> Connected Accounts.
/// Required, not skippable — an admin reviews every creator's connected
/// Instagram before their dashboard unlocks (see
/// [CreatorVerificationPendingScreen]), so there needs to be real data to
/// review.
class CreatorInstagramConnectScreen extends ConsumerWidget {
  const CreatorInstagramConnectScreen({super.key});

  Future<void> _connectInstagram(BuildContext context, WidgetRef ref) async {
    await ref.read(instagramControllerProvider.notifier).connect(context);
    if (!context.mounted) return;
    final error = ref.read(instagramControllerProvider).error;
    if (error != null) {
      if (error is InstagramAuthCancelledException) return;
      AppSnackbar.showError(
        context,
        error is InstagramApiException
            ? error.message
            : "Couldn't connect Instagram. Please try again.",
      );
      return;
    }

    await ref.read(authControllerProvider.notifier).completeOnboarding();
    if (!context.mounted) return;
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final isConnecting = ref.watch(instagramControllerProvider).isLoading;

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
              const AuthHeader(
                title: 'Connect Instagram',
                subtitle:
                    'Required to verify your reach before your profile can '
                    'be reviewed',
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(AppSpacing.card),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Row(
                  children: [
                    const InstagramIcon(size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Brands see your real follower count and engagement '
                        'once Instagram is connected.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AuthButton(
                text: 'Connect Instagram',
                isLoading: isLoading || isConnecting,
                onPressed: (isLoading || isConnecting)
                    ? null
                    : () => _connectInstagram(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
