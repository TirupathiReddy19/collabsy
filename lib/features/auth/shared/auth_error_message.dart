import 'package:firebase_auth/firebase_auth.dart';

/// Every sign-in path (password, phone OTP, Google, Apple) can hit
/// `user-disabled` the moment an account gets suspended (see
/// `suspendUserAccount` and its Danger Zone button in the admin portal) —
/// surfaced here as one clear message instead of whichever generic
/// "sign-in failed" text each call site would otherwise show.
String authErrorMessage(Object? error, String fallback) {
  if (error is FirebaseAuthException && error.code == 'user-disabled') {
    return 'This account has been suspended. Contact support@collabsy.online '
        'if you think this is a mistake.';
  }
  return fallback;
}
