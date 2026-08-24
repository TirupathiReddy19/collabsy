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
  if (error is FirebaseAuthException && error.code == 'too-many-requests') {
    // Firebase's phone-auth abuse throttle — same generic code whether it's
    // this specific number or this device that tripped it. Worth telling
    // apart from an actually-wrong code, which is what the OTP screens'
    // fallback text otherwise implies.
    return "Too many attempts from this device. Please wait a while before "
        'trying again.';
  }
  return fallback;
}
