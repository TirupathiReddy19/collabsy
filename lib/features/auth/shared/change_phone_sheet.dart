import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/otp_input.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_providers.dart';

enum _Stage { enterPhone, enterOtp, reauth }

/// Bottom sheet for changing the signed-in user's phone number — enters a
/// new number, verifies it via a fresh OTP (distinct from the one used at
/// signup), and falls back to a password re-auth prompt if Firebase
/// requires a fresher session for this security-sensitive change.
class ChangePhoneSheet extends ConsumerStatefulWidget {
  const ChangePhoneSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ChangePhoneSheet(),
    );
  }

  @override
  ConsumerState<ChangePhoneSheet> createState() => _ChangePhoneSheetState();
}

class _ChangePhoneSheetState extends ConsumerState<ChangePhoneSheet> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  _Stage _stage = _Stage.enterPhone;
  String? _verificationId;
  String? _pendingSmsCode;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final verificationId = await ref
        .read(authControllerProvider.notifier)
        .sendPhoneOtp(_phoneController.text.trim());
    if (!mounted) return;
    if (verificationId == null) {
      AppSnackbar.showError(
        context,
        "Couldn't send the code. Please try again.",
      );
      return;
    }
    setState(() {
      _verificationId = verificationId;
      _stage = _Stage.enterOtp;
    });
  }

  Future<void> _verify(String smsCode) async {
    await ref
        .read(authControllerProvider.notifier)
        .changePhoneNumber(verificationId: _verificationId!, smsCode: smsCode);
    if (!mounted) return;
    final error = ref.read(authControllerProvider).error;
    if (error == null) {
      AppSnackbar.showSuccess(context, 'Phone number updated.');
      Navigator.of(context).pop(true);
      return;
    }
    if (error is FirebaseAuthException &&
        error.code == 'requires-recent-login') {
      setState(() {
        _pendingSmsCode = smsCode;
        _stage = _Stage.reauth;
      });
      return;
    }
    AppSnackbar.showError(
      context,
      "Couldn't verify the code. Please try again.",
    );
  }

  Future<void> _reauthAndRetry() async {
    if (_passwordController.text.isEmpty) return;
    await ref
        .read(authControllerProvider.notifier)
        .reauthenticateWithPassword(_passwordController.text);
    if (!mounted) return;
    if (ref.read(authControllerProvider).hasError) {
      AppSnackbar.showError(context, 'Incorrect password.');
      return;
    }
    await _verify(_pendingSmsCode!);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenHorizontal,
        right: AppSpacing.screenHorizontal,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: switch (_stage) {
        _Stage.enterPhone => Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change phone number', style: AppTextStyles.titleLarge),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneController,
                label: 'New phone number',
                hintText: '98765 43210',
                keyboardType: TextInputType.phone,
                enabled: !isLoading,
                autofocus: true,
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Send code',
                isLoading: isLoading,
                onPressed: isLoading ? null : _sendOtp,
              ),
            ],
          ),
        ),
        _Stage.enterOtp => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter the code', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Sent to ${_phoneController.text.trim()}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),
            OtpInput(enabled: !isLoading, onCompleted: _verify),
            const SizedBox(height: 16),
            if (isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
        _Stage.reauth => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirm your password', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              'For your security, please re-enter your password to continue.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
              enabled: !isLoading,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Confirm',
              isLoading: isLoading,
              onPressed: isLoading ? null : _reauthAndRetry,
            ),
          ],
        ),
      },
    );
  }
}
