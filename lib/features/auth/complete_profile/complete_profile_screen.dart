import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../shared/models/user_role.dart';
import '../providers/auth_providers.dart';
import '../shared/auth_button.dart';
import '../shared/auth_header.dart';
import '../shared/otp_verification_view.dart';
import '../shared/role_tab_selector.dart';

/// Shown after any sign-in that has no [UserRole] yet — a Google sign-in
/// (which never gives us a phone number), an email/password signup
/// returning from its confirmation link after a cold start (in which case
/// the role/name/phone typed during signup are pre-filled from the local
/// cache [LocalStorageService.savePendingSignup] left behind), or a phone
/// **login** attempt on a number that turned out to be unregistered —
/// Firebase's phone auth can't tell sign-in from sign-up apart, so that
/// last case already has a verified phone (the account's own identity) and
/// just needs a role and an email (sent a `verifyBeforeUpdateEmail` link,
/// same as password-signup's confirmation email — see
/// [_alreadyVerifiedPhone]).
///
/// For the signup-cache case the role/phone are already known — the role
/// tab is locked (re-picking it here would be confusing, not useful) and
/// the phone OTP is sent automatically so the user never has to tap through
/// a form they already filled in at signup. It only surfaces if that
/// auto-send fails, so they can retry or fix a mistyped number.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  UserRole _role = UserRole.creator;
  String? _pendingDisplayName;
  bool _roleLocked = false;
  bool _autoSubmitted = false;
  // Set when this account's identity already *is* a verified phone number
  // (a phone-login attempt on an unregistered number, which Firebase turns
  // into a brand-new bare account) — Google/Apple never populate this, and
  // the email/password path only gets a phone once this screen links one,
  // so a non-null value here can only mean that case.
  String? _alreadyVerifiedPhone;

  @override
  void initState() {
    super.initState();
    final localStorage = ref.read(localStorageServiceProvider);
    final pendingRole = UserRole.fromDbValue(localStorage.pendingSignupRole);
    if (pendingRole != null) {
      _role = pendingRole;
      _roleLocked = true;
      _pendingDisplayName = localStorage.pendingSignupDisplayName;
      _phoneController.text = localStorage.pendingSignupPhone ?? '';
      // Not cleared here: if phone verification fails (or the app restarts
      // before it succeeds), this screen reloads from scratch and needs
      // this data again. It's only cleared once role assignment actually
      // succeeds — see OtpVerificationView._handleCompleted.

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_autoSubmitted && mounted) {
          _autoSubmitted = true;
          _continue();
        }
      });
    } else {
      _alreadyVerifiedPhone = ref
          .read(authRepositoryProvider)
          .currentUser
          ?.phoneNumber;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;

    final alreadyVerifiedPhone = _alreadyVerifiedPhone;
    if (alreadyVerifiedPhone != null) {
      // The phone is already this account's own verified identity (see
      // initState) — sending another OTP would just try to re-link a
      // credential the account already has. Skip straight to assigning the
      // role instead of routing back through OtpVerificationView.
      await ref
          .read(authControllerProvider.notifier)
          .chooseRole(
            _role,
            displayName: _pendingDisplayName,
            phone: alreadyVerifiedPhone,
          );
      if (!mounted) return;
      if (ref.read(authControllerProvider).hasError) {
        AppSnackbar.showError(
          context,
          "Couldn't finish setting up your account.",
        );
        return;
      }

      // The role's already saved at this point (harmless to redo if the
      // step below fails and this whole method re-runs on retry — setRole
      // merges rather than duplicating). Only advance to checkEmail once
      // the verification link genuinely sent; otherwise the user would be
      // stuck on a screen waiting for an email that never went out.
      final email = _emailController.text.trim();
      await ref
          .read(authControllerProvider.notifier)
          .verifyBeforeUpdateEmail(email);
      if (!mounted) return;
      if (ref.read(authControllerProvider).hasError) {
        final error = ref.read(authControllerProvider).error;
        AppSnackbar.showError(
          context,
          error is FirebaseAuthException && error.code == 'email-already-in-use'
              ? 'That email is already in use by another account.'
              : "Couldn't send a verification email. Please try again.",
        );
        return;
      }
      await ref
          .read(localStorageServiceProvider)
          .savePendingPhoneEmailVerification(email);
      if (!mounted) return;
      context.go(AppRoutes.checkEmail);
      return;
    }

    final phone = _phoneController.text.trim();
    final verificationId = await ref
        .read(authControllerProvider.notifier)
        .sendPhoneOtp(phone, link: true);
    if (!mounted) return;

    if (ref.read(authControllerProvider).hasError || verificationId == null) {
      AppSnackbar.showError(
        context,
        "Couldn't send the code. Please try again.",
      );
      return;
    }

    final profile = ref.read(currentProfileProvider).value;

    ref
        .read(pendingOtpProvider.notifier)
        .set(
          OtpVerificationArgs(
            phone: phone,
            verificationId: verificationId,
            role: _role,
            displayName: _pendingDisplayName ?? profile?.displayName,
          ),
        );
    context.push(AppRoutes.otp);
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
                AuthHeader(
                  title: 'A couple more details',
                  subtitle: _roleLocked
                      ? 'Verifying your phone number...'
                      : _alreadyVerifiedPhone != null
                      ? "${_alreadyVerifiedPhone!} isn't registered yet — "
                            'pick a role and add an email to finish creating '
                            'your account'
                      : "We just need your role and phone to finish setting up your account",
                ),
                const SizedBox(height: 24),
                if (_roleLocked)
                  _LockedRole(role: _role)
                else
                  RoleTabSelector(
                    selected: _role,
                    onChanged: isLoading
                        ? (_) {}
                        : (role) => setState(() => _role = role),
                  ),
                const SizedBox(height: 24),
                if (_alreadyVerifiedPhone == null)
                  AppTextField(
                    controller: _phoneController,
                    label: 'Phone number',
                    hintText: '98765 43210',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    validator: Validators.phone,
                    onSubmitted: (_) => _continue(),
                  )
                else
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    validator: Validators.email,
                    onSubmitted: (_) => _continue(),
                  ),
                const SizedBox(height: 24),
                AuthButton(
                  text: 'Continue',
                  onPressed: isLoading ? null : _continue,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () => ref
                              .read(authControllerProvider.notifier)
                              .signOut(),
                    child: const Text('Sign out'),
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

/// Non-interactive stand-in for [RoleTabSelector] when the role was already
/// chosen at signup — shown while the phone OTP auto-sends.
class _LockedRole extends StatelessWidget {
  const _LockedRole({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 18, color: AppColors.primaryDark),
          const SizedBox(width: 8),
          Text(
            'Signing up as ${role == UserRole.creator ? 'Creator' : 'Brand / Agency'}',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
