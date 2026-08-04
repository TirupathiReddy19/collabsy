import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/otp_input.dart';
import '../providers/auth_providers.dart';
import '../shared/auth_header.dart';

/// Shown when [AuthController.signInWithPassword] hits a 2FA challenge —
/// asks for the current code from the user's authenticator app and
/// resolves the sign-in with it. Nothing is "sent"; TOTP codes are
/// generated locally by the app the user already enrolled.
class MfaChallengeScreen extends ConsumerStatefulWidget {
  const MfaChallengeScreen({super.key});

  @override
  ConsumerState<MfaChallengeScreen> createState() => _MfaChallengeScreenState();
}

class _MfaChallengeScreenState extends ConsumerState<MfaChallengeScreen> {
  Future<void> _handleCompleted(String code) async {
    await ref
        .read(authControllerProvider.notifier)
        .resolveMfaSignIn(oneTimePassword: code);
    if (!mounted) return;
    if (ref.read(authControllerProvider).hasError) {
      AppSnackbar.showError(
        context,
        'Invalid or expired code. Please try again.',
      );
      return;
    }
    context.go(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

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
                title: 'Two-factor verification',
                subtitle: 'Enter the 6-digit code from your authenticator app.',
              ),
              const SizedBox(height: 32),
              OtpInput(onCompleted: _handleCompleted, enabled: !isLoading),
              if (isLoading) ...[
                const SizedBox(height: 24),
                const Center(child: LoadingIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
