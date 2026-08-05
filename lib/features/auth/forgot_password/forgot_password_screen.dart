import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';
import '../shared/auth_button.dart';
import '../shared/auth_header.dart';

/// Sends a real Firebase password-reset link — the user finishes on
/// Firebase's own hosted web page and comes back to log in with the new
/// password, so there's nothing here to poll for.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
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
    AppSnackbar.showSuccess(context, 'Reset link sent to $email.');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.screenVertical,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(
                  title: 'Trouble signing in?',
                  subtitle:
                      "Enter your email and we'll send you a link to reset "
                      "your password.",
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  validator: Validators.email,
                  onSubmitted: (_) => _sendResetLink(),
                ),
                const SizedBox(height: 24),
                AuthButton(
                  text: _sent ? 'Send again' : 'Send reset link',
                  onPressed: isLoading ? null : _sendResetLink,
                  isLoading: isLoading,
                ),
                if (_sent) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Check your inbox, reset your password there, then come '
                    'back and log in.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Text('Still stuck?', style: AppTextStyles.titleSmall),
                const SizedBox(height: 8),
                Text(
                  'Reach us at support@collabsy.online and we\'ll help you '
                  'get back into your account.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Back to login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
