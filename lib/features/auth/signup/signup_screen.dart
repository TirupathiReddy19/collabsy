import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../shared/models/user_role.dart';
import '../providers/auth_providers.dart';
import '../shared/auth_button.dart';
import '../shared/auth_header.dart';
import '../shared/role_tab_selector.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _role = UserRole.creator;
  int _step = 0;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _continueToStep2() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _step = 1);
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    // Cache role/name/phone BEFORE creating the account, not after: account
    // creation signs the user in immediately, which the router's redirect
    // guard reacts to right away (sending them to check-email) — that
    // unmounts this screen before any code placed after signUpWithPassword()
    // would get a chance to run, silently skipping the save every time.
    await ref
        .read(localStorageServiceProvider)
        .savePendingSignup(
          role: _role.toDbValue(),
          displayName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
    if (!mounted) return;

    final controller = ref.read(authControllerProvider.notifier);
    await controller.signUpWithPassword(
      email: email,
      password: _passwordController.text,
    );
    if (!mounted) return;

    if (ref.read(authControllerProvider).hasError) {
      // Account was never actually created — the cached data doesn't
      // correspond to anything in progress, so don't leave it lingering.
      await ref.read(localStorageServiceProvider).clearPendingSignup();
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        "Couldn't create your account. Please try again.",
      );
      return;
    }

    if (mounted) context.go(AppRoutes.checkEmail);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final isBrand = _role == UserRole.brand;
    final isStep2 = _step == 1;

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
                AuthHeader(
                  title: 'Create your account',
                  subtitle: isStep2
                      ? 'Step 2 of 2 — secure your account'
                      : "Step 1 of 2 — tell us who you are",
                ),
                const SizedBox(height: 24),
                if (!isStep2) ...[
                  RoleTabSelector(
                    selected: _role,
                    onChanged: isLoading
                        ? (_) {}
                        : (role) => setState(() => _role = role),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    controller: _nameController,
                    label: 'Full name',
                    hintText: 'Priya Sharma',
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'This field is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _emailController,
                    label: isBrand ? 'Work email' : 'Email',
                    hintText: isBrand ? 'you@yourbrand.com' : 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    validator: isBrand
                        ? Validators.workEmail
                        : Validators.email,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _phoneController,
                    label: 'Phone number',
                    hintText: '98765 43210',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    validator: Validators.phone,
                    onSubmitted: (_) => _continueToStep2(),
                  ),
                  const SizedBox(height: 24),
                  AuthButton(text: 'Continue', onPressed: _continueToStep2),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: isLoading ? null : () => context.pop(),
                      child: const Text('Already have an account? Log in'),
                    ),
                  ),
                ] else ...[
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: 'Min. 8 characters',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    validator: Validators.password,
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
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm password',
                    hintText: 'Re-enter your password',
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    validator: Validators.confirmPassword(_passwordController),
                    onSubmitted: (_) => _createAccount(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AuthButton(
                    text: 'Create account',
                    onPressed: isLoading ? null : _createAccount,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () => setState(() => _step = 0),
                      child: Text('Back', style: AppTextStyles.link),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
