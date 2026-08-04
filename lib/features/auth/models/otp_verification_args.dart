import '../../../shared/models/user_role.dart';

/// Arguments for the phone OTP screen (email now verifies via a tapped
/// confirmation/magic link instead — see `check_email_screen.dart`).
///
/// Passed through the [pendingOtpArgsProvider] rather than GoRouter's route
/// `extra` — `extra` gets dropped when the router re-evaluates its redirect
/// guard mid-flow (e.g. the moment phone verification itself changes the
/// signed-in auth state), which crashes the OTP screen's route builder.
/// App state survives that; `extra` doesn't.
///
/// [role] is set only when this is finishing a signup (fresh account or
/// Google sign-in completing its profile) — once the code verifies, the
/// screen also writes that role (and [displayName]) to the profile, and
/// links the phone credential to that existing account instead of signing
/// in as a brand new one.
///
/// [expectedRole] is set only for a plain phone login (mutually exclusive
/// with [role]) — the tab the user picked on the login screen, checked
/// against the account's real stored role once verification succeeds, so
/// picking the wrong tab for an existing account is rejected rather than
/// silently letting them in and rerouting.
class OtpVerificationArgs {
  const OtpVerificationArgs({
    required this.phone,
    required this.verificationId,
    this.role,
    this.expectedRole,
    this.displayName,
  });

  final String phone;
  final String verificationId;
  final UserRole? role;
  final UserRole? expectedRole;
  final String? displayName;
}
