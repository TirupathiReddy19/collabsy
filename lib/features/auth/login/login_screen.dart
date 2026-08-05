import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../shared/models/user_role.dart';
import '../providers/auth_providers.dart';
import '../shared/auth_button.dart';
import '../shared/auth_error_message.dart';
import '../shared/auth_header.dart';
import '../shared/otp_verification_view.dart';
import '../shared/role_tab_selector.dart';
import '../shared/social_button.dart';

/// Note: the Creator/Brand tab here only gates the Google/Apple sign-in
/// buttons' visibility — the account you actually log into (and which
/// dashboard you land on) is always determined by your account's real
/// stored role, not by whichever tab is selected. A given
/// email/phone/Google/Apple identity belongs to exactly one existing
/// account with a fixed role.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _role = UserRole.creator;
  IdentifierType _identifierType = IdentifierType.unknown;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onIdentifierChanged(String value) {
    final type = Validators.detectIdentifierType(value);
    if (type != _identifierType) {
      setState(() => _identifierType = type);
    }
  }

  Future<void> _signInWithPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _identifierController.text.trim();
    final mfaRequired = await ref
        .read(authControllerProvider.notifier)
        .signInWithPassword(email: email, password: _passwordController.text);
    if (!mounted) return;

    if (mfaRequired) {
      context.push(AppRoutes.mfaChallenge);
      return;
    }

    if (ref.read(authControllerProvider).hasError) {
      AppSnackbar.showError(
        context,
        authErrorMessage(
          ref.read(authControllerProvider).error,
          'Incorrect email or password. Please try again.',
        ),
      );
      return;
    }

    await _enforceSelectedRole();
    // If it matched, the auth-state stream flips the router's redirect
    // guard to the right dashboard — nothing else to do here.
  }

  Future<void> _sendPhoneOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _identifierController.text.trim();
    final verificationId = await ref
        .read(authControllerProvider.notifier)
        .sendPhoneOtp(phone);
    if (!mounted) return;

    if (ref.read(authControllerProvider).hasError || verificationId == null) {
      AppSnackbar.showError(
        context,
        "Couldn't send the code. Please try again.",
      );
      return;
    }

    ref
        .read(pendingOtpProvider.notifier)
        .set(
          OtpVerificationArgs(
            phone: phone,
            verificationId: verificationId,
            expectedRole: _role,
          ),
        );
    context.push(AppRoutes.otp);
  }

  Future<void> _continueWithGoogle() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    if (ref.read(authControllerProvider).hasError) {
      AppSnackbar.showError(
        context,
        authErrorMessage(
          ref.read(authControllerProvider).error,
          'Google sign-in failed. Please try again.',
        ),
      );
      return;
    }

    await _enforceSelectedRole();
  }

  Future<void> _continueWithApple() async {
    await ref.read(authControllerProvider.notifier).signInWithApple();
    if (!mounted) return;
    if (ref.read(authControllerProvider).hasError) {
      AppSnackbar.showError(
        context,
        authErrorMessage(
          ref.read(authControllerProvider).error,
          'Apple sign-in failed. Please try again.',
        ),
      );
      return;
    }

    await _enforceSelectedRole();
  }

  /// Signs back out and shows an error if the account just signed into
  /// doesn't match the tab selected — see [AuthController.checkRoleMismatch].
  Future<void> _enforceSelectedRole() async {
    final mismatch = await ref
        .read(authControllerProvider.notifier)
        .checkRoleMismatch(_role);
    if (!mounted || mismatch == null) return;
    AppSnackbar.showError(
      context,
      'Please log in from the ${mismatch.label} tab.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final isEmail = _identifierType == IdentifierType.email;
    final isPhone = _identifierType == IdentifierType.phone;

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
                const AuthHeader(title: 'Welcome back'),
                const SizedBox(height: 24),
                RoleTabSelector(
                  selected: _role,
                  onChanged: isLoading
                      ? (_) {}
                      : (role) => setState(() => _role = role),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _identifierController,
                  label: 'Email or Mobile Number',
                  hintText: 'you@example.com or +91 mobile',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  onChanged: _onIdentifierChanged,
                  validator: isPhone ? Validators.phone : Validators.email,
                ),
                if (isEmail) ...[
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Enter your password'
                        : null,
                    onSubmitted: (_) => _signInWithPassword(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (isPhone)
                  AuthButton(
                    text: 'Send OTP',
                    onPressed: isLoading ? null : _sendPhoneOtp,
                    isLoading: isLoading,
                  )
                else
                  AuthButton(
                    text: 'Sign in',
                    onPressed: isLoading ? null : _signInWithPassword,
                    isLoading: isLoading,
                  ),
                if (_role == UserRole.creator) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or', style: AppTextStyles.bodySmall),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SocialButton(
                    label: 'Continue with Google',
                    onPressed: isLoading ? null : _continueWithGoogle,
                    isLoading: isLoading,
                  ),
                  if (Platform.isIOS) ...[
                    const SizedBox(height: 12),
                    AppleSignInButton(
                      onPressed: isLoading ? null : _continueWithApple,
                      isLoading: isLoading,
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.push(AppRoutes.signup),
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.push(AppRoutes.help),
                    child: const Text('Having trouble signing in?'),
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
