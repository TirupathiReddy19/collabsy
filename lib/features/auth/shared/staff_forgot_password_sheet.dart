import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_providers.dart';

/// Shared "forgot password" bottom sheet for the staff-only sign-in screens
/// — Admin, Outreach Intern, Brand Outreach Intern. All three sign in
/// through the same Firebase Auth project as everything else, so the same
/// `sendPasswordResetEmail` the main app's `ForgotPasswordScreen` uses works
/// here too; this just gives these password-only staff logins a way to
/// reach it without a dedicated route, mirroring `ChangeEmailSheet`'s shape.
class StaffForgotPasswordSheet extends ConsumerStatefulWidget {
  const StaffForgotPasswordSheet({super.key, this.initialEmail});

  final String? initialEmail;

  static Future<void> show(BuildContext context, {String? initialEmail}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StaffForgotPasswordSheet(
        initialEmail: initialEmail,
      ),
    );
  }

  @override
  ConsumerState<StaffForgotPasswordSheet> createState() =>
      _StaffForgotPasswordSheetState();
}

class _StaffForgotPasswordSheetState
    extends ConsumerState<StaffForgotPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    await ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(email);
    if (!mounted) return;

    if (ref.read(authControllerProvider).hasError) {
      AppSnackbar.showError(
        context,
        "Couldn't send the link. Please try again.",
      );
      return;
    }
    setState(() => _sent = true);
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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reset your password', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              "Enter your account email and we'll send you a link to reset "
              'your password.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              enabled: !isLoading && !_sent,
              autofocus: true,
              validator: Validators.email,
              onSubmitted: (_) => _send(),
            ),
            const SizedBox(height: 16),
            if (_sent)
              Text(
                'Check your inbox, reset your password there, then come '
                'back and sign in.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.success,
                ),
              )
            else
              PrimaryButton(
                text: 'Send reset link',
                isLoading: isLoading,
                onPressed: isLoading ? null : _send,
              ),
          ],
        ),
      ),
    );
  }
}
