import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_providers.dart';

enum _Stage { enterEmail, checkInbox, reauth }

/// Bottom sheet for changing the signed-in user's email — Firebase only
/// applies the change once the user clicks a verification link sent to
/// the new address, so this walks them through sending it and then
/// confirming once they've clicked it.
class ChangeEmailSheet extends ConsumerStatefulWidget {
  const ChangeEmailSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ChangeEmailSheet(),
    );
  }

  @override
  ConsumerState<ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends ConsumerState<ChangeEmailSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  _Stage _stage = _Stage.enterEmail;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendVerification() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .changeEmail(_emailController.text.trim());
    if (!mounted) return;
    final error = ref.read(authControllerProvider).error;
    if (error == null) {
      setState(() => _stage = _Stage.checkInbox);
      return;
    }
    if (error is FirebaseAuthException &&
        error.code == 'requires-recent-login') {
      setState(() => _stage = _Stage.reauth);
      return;
    }
    AppSnackbar.showError(
      context,
      "Couldn't send the verification email. Please try again.",
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
    await _sendVerification();
  }

  Future<void> _checkVerified() async {
    final verified = await ref
        .read(authControllerProvider.notifier)
        .checkEmailChangeVerified(_emailController.text.trim());
    if (!mounted) return;
    if (verified) {
      AppSnackbar.showSuccess(context, 'Email updated.');
      Navigator.of(context).pop(true);
      return;
    }
    AppSnackbar.showInfo(
      context,
      "Not verified yet — click the link in the email we sent, then try again.",
    );
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
        _Stage.enterEmail => Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change email', style: AppTextStyles.titleLarge),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailController,
                label: 'New email address',
                hintText: 'you@company.com',
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
                autofocus: true,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Send verification link',
                isLoading: isLoading,
                onPressed: isLoading ? null : _sendVerification,
              ),
            ],
          ),
        ),
        _Stage.checkInbox => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Check your inbox', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              "We've sent a verification link to "
              "${_emailController.text.trim()}. Click it, then come back "
              'and tap below.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: "I've verified — Refresh",
              isLoading: isLoading,
              onPressed: isLoading ? null : _checkVerified,
            ),
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
