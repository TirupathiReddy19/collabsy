import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/firebase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../features/auth/providers/auth_providers.dart';

const _outreachPermission = '/outreach-leads';

/// Sign-in only, mirrors `admin_login_screen.dart`'s shape — but an intern
/// account is authorized only when its `staffAccounts` doc is active AND
/// specifically has the `/outreach-leads` permission granted (via Role
/// Management in the Admin portal). Every other staff account, including
/// the super admin, is rejected here — this tool shows nothing else.
class InternLoginScreen extends ConsumerStatefulWidget {
  const InternLoginScreen({super.key});

  @override
  ConsumerState<InternLoginScreen> createState() => _InternLoginScreenState();
}

class _InternLoginScreenState extends ConsumerState<InternLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    final mfaPending = await ref
        .read(authControllerProvider.notifier)
        .signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;

    if (ref.read(authControllerProvider).hasError) {
      AppSnackbar.showError(context, 'Incorrect email or password.');
      return;
    }
    if (mfaPending) {
      AppSnackbar.showError(
        context,
        'Two-factor accounts are not supported here yet.',
      );
      await ref.read(authRepositoryProvider).signOut();
      return;
    }

    final user = ref.read(authRepositoryProvider).currentUser;
    final staffData = user == null ? null : await _staffAccountData(user.uid);
    final active = staffData?['active'] as bool? ?? false;
    final permissions = Map<String, bool>.from(
      (staffData?['permissions'] as Map?) ?? const {},
    );
    final isAuthorized = active && permissions[_outreachPermission] == true;

    if (user == null || !isAuthorized) {
      await ref.read(authRepositoryProvider).signOut();
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        'This account is not authorized for the outreach tool.',
      );
      return;
    }
    // Authorized — the router's redirect takes over automatically once
    // authStateChanges updates.
  }

  Future<Map<String, dynamic>?> _staffAccountData(String uid) async {
    final doc = await ref
        .read(firestoreProvider)
        .collection('staffAccounts')
        .doc(uid)
        .get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: StaggeredFadeIn(
              child: Card(
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Collabsy',
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Outreach Tool',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          controller: _emailController,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isLoading,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Enter your email'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: true,
                          enabled: !isLoading,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _signIn(),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Enter your password'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: 'Sign in',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _signIn,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
