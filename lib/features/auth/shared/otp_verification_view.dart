import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/otp_input.dart';
import '../models/otp_verification_args.dart';
import '../providers/auth_providers.dart';
import 'auth_error_message.dart';
import 'auth_header.dart';

export '../models/otp_verification_args.dart';

class OtpVerificationView extends ConsumerStatefulWidget {
  const OtpVerificationView({super.key});

  @override
  ConsumerState<OtpVerificationView> createState() =>
      _OtpVerificationViewState();
}

class _OtpVerificationViewState extends ConsumerState<OtpVerificationView> {
  static const _resendSeconds = 30;

  Timer? _resendTimer;
  int _secondsRemaining = _resendSeconds;
  late OtpVerificationArgs _args;
  late String _verificationId;

  @override
  void initState() {
    super.initState();
    final args = ref.read(pendingOtpProvider);
    if (args == null) {
      // Shouldn't happen if every caller sets pendingOtpProvider before
      // navigating here — bail out safely instead of crashing on a null
      // dereference below.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.login);
      });
      _args = const OtpVerificationArgs(phone: '', verificationId: '');
      _verificationId = '';
      return;
    }
    _args = args;
    _verificationId = args.verificationId;
    _startResendCountdown();
  }

  void _startResendCountdown() {
    setState(() => _secondsRemaining = _resendSeconds);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleCompleted(String code) async {
    final controller = ref.read(authControllerProvider.notifier);
    final role = _args.role;
    var isNewUser = false;

    if (role != null) {
      await controller.linkPhoneCredential(
        verificationId: _verificationId,
        smsCode: code,
      );
    } else {
      isNewUser =
          await controller.verifyPhoneOtp(
            verificationId: _verificationId,
            smsCode: code,
          ) ??
          false;
    }
    if (!mounted) return;

    final verifyState = ref.read(authControllerProvider);
    if (verifyState.hasError) {
      final error = verifyState.error;
      // A phone number can only ever belong to one Firebase account —
      // Firebase itself enforces this (it's what guarantees a number
      // can't be used for both a Creator and a Brand account), this just
      // surfaces that as a clear message instead of a generic OTP error.
      final message =
          error is FirebaseAuthException &&
              error.code == 'credential-already-in-use'
          ? 'This phone number is already linked to another account.'
          : authErrorMessage(
              error,
              'Invalid or expired code. Please try again.',
            );
      AppSnackbar.showError(context, message);
      return;
    }

    if (role != null) {
      await controller.chooseRole(
        role,
        displayName: _args.displayName,
        phone: _args.phone,
      );
      if (!mounted) return;
      if (ref.read(authControllerProvider).hasError) {
        AppSnackbar.showError(
          context,
          "Couldn't finish setting up your account.",
        );
        return;
      }
      // Only clear now that the role is actually saved — if we cleared it
      // earlier (e.g. right when complete-profile first loaded) and this
      // verification step failed or the app restarted, that pending data
      // would be gone with nothing to show for it.
      await ref.read(localStorageServiceProvider).clearPendingSignup();
      if (!mounted) return;
    } else if (isNewUser) {
      // This phone number had no account at all — Firebase's phone auth
      // can't tell "sign in" from "sign up" apart, so verifying the code
      // just created a bare, role-less account rather than logging into an
      // existing one. Send them straight into finishing signup instead of
      // silently leaving them on a blank "complete your profile" form with
      // no explanation.
      ref.read(pendingOtpProvider.notifier).clear();
      AppSnackbar.showInfo(
        context,
        "This number isn't registered yet — let's finish setting up your "
        'account.',
      );
      if (mounted) context.go(AppRoutes.completeProfile);
      return;
    } else if (_args.expectedRole != null) {
      // Plain phone login — reject it if this account's real role doesn't
      // match the tab picked on the login screen, rather than silently
      // letting them in and rerouting to the other dashboard.
      final mismatch = await controller.checkRoleMismatch(_args.expectedRole!);
      if (!mounted) return;
      if (mismatch != null) {
        ref.read(pendingOtpProvider.notifier).clear();
        AppSnackbar.showError(
          context,
          'Please log in from the ${mismatch.label} tab.',
        );
        context.go(AppRoutes.login);
        return;
      }
    }

    ref.read(pendingOtpProvider.notifier).clear();
    if (mounted) context.go(AppRoutes.splash);
  }

  Future<void> _resend() async {
    final verificationId = await ref
        .read(authControllerProvider.notifier)
        .sendPhoneOtp(_args.phone, link: _args.role != null);
    if (!mounted) return;
    if (ref.read(authControllerProvider).hasError || verificationId == null) {
      AppSnackbar.showError(
        context,
        "Couldn't resend the code. Please try again.",
      );
      return;
    }
    _verificationId = verificationId;
    _args = OtpVerificationArgs(
      phone: _args.phone,
      verificationId: verificationId,
      role: _args.role,
      displayName: _args.displayName,
    );
    ref.read(pendingOtpProvider.notifier).set(_args);
    _startResendCountdown();
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
              AuthHeader(
                title: 'Enter verification code',
                subtitle: 'We sent a 6-digit code to ${_args.phone}',
              ),
              const SizedBox(height: 32),
              OtpInput(onCompleted: _handleCompleted, enabled: !isLoading),
              const SizedBox(height: 24),
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        'Resend code in ${_secondsRemaining}s',
                        style: AppTextStyles.bodyMedium,
                      )
                    : TextButton(
                        onPressed: isLoading ? null : _resend,
                        child: const Text('Resend code'),
                      ),
              ),
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
