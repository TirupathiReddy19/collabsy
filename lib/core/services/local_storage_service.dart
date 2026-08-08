import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'local_storage_service.g.dart';

const _hasSeenOnboardingKey = 'has_seen_onboarding';
const _pendingSignupRoleKey = 'pending_signup_role';
const _pendingSignupDisplayNameKey = 'pending_signup_display_name';
const _pendingSignupPhoneKey = 'pending_signup_phone';
const _pendingPhoneEmailVerificationKey = 'pending_phone_email_verification';

/// Overridden in `main()` with the real [SharedPreferences] instance once
/// it's been awaited — everything else reads it through this provider.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
});

/// Small device-local flags that don't belong in the database
/// (e.g. "has this device seen the onboarding carousel").
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  bool get hasSeenOnboarding => _prefs.getBool(_hasSeenOnboardingKey) ?? false;

  Future<void> setHasSeenOnboarding(bool value) {
    return _prefs.setBool(_hasSeenOnboardingKey, value);
  }

  /// The role/name/phone collected during signup get cached here right
  /// before the confirmation email is sent, since the OS may kill the app
  /// in the background while the user checks their inbox — the in-memory
  /// signup form state can be long gone by the time they come back. Read
  /// once by the complete-profile screen, then cleared.
  Future<void> savePendingSignup({
    required String role,
    required String displayName,
    required String phone,
  }) async {
    await _prefs.setString(_pendingSignupRoleKey, role);
    await _prefs.setString(_pendingSignupDisplayNameKey, displayName);
    await _prefs.setString(_pendingSignupPhoneKey, phone);
  }

  String? get pendingSignupRole => _prefs.getString(_pendingSignupRoleKey);
  String? get pendingSignupDisplayName =>
      _prefs.getString(_pendingSignupDisplayNameKey);
  String? get pendingSignupPhone => _prefs.getString(_pendingSignupPhoneKey);

  Future<void> clearPendingSignup() async {
    await _prefs.remove(_pendingSignupRoleKey);
    await _prefs.remove(_pendingSignupDisplayNameKey);
    await _prefs.remove(_pendingSignupPhoneKey);
  }

  /// A phone-first account (see [CompleteProfileScreen]'s
  /// `_alreadyVerifiedPhone` case) has no `password` provider, so
  /// `Auth.currentUser.email` stays null until its `verifyBeforeUpdateEmail`
  /// link is actually clicked — there's no Firebase-native signal to gate
  /// on in the meantime, unlike the password-signup path's `providerData`.
  /// This cached value is that signal: set right before the verification
  /// email is sent, read by the router to hold the account on
  /// [AppRoutes.checkEmail], and cleared once verification succeeds.
  Future<void> savePendingPhoneEmailVerification(String email) {
    return _prefs.setString(_pendingPhoneEmailVerificationKey, email);
  }

  String? get pendingPhoneEmailVerification =>
      _prefs.getString(_pendingPhoneEmailVerificationKey);

  Future<void> clearPendingPhoneEmailVerification() {
    return _prefs.remove(_pendingPhoneEmailVerificationKey);
  }

  /// Whether the Home screen's profile-completeness card has already
  /// played its one-time celebration for this user — keyed by uid so a
  /// shared device with multiple accounts doesn't cross-pollinate.
  bool hasCelebratedProfileComplete(String userId) =>
      _prefs.getBool('profile_complete_celebrated_$userId') ?? false;

  Future<void> setCelebratedProfileComplete(String userId) {
    return _prefs.setBool('profile_complete_celebrated_$userId', true);
  }
}

@Riverpod(keepAlive: true)
LocalStorageService localStorageService(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
}
