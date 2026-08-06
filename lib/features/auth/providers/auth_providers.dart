import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/firebase_service.dart';
import '../../../shared/models/user_role.dart';
import '../data/auth_repository.dart';
import '../models/app_user_profile.dart';
import '../models/otp_verification_args.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
    ref.watch(firebaseStorageProvider),
    ref.watch(firebaseFunctionsProvider),
  );
}

@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// The signed-in user's `users` Firestore document (including chosen
/// [UserRole]), or null when there's no session. Refetches whenever auth
/// state changes.
@Riverpod(keepAlive: true)
class CurrentProfile extends _$CurrentProfile {
  @override
  Future<AppUserProfile?> build() async {
    ref.watch(authStateChangesProvider);

    final repository = ref.watch(authRepositoryProvider);
    final user = repository.currentUser;
    if (user == null) return null;

    final profile = await repository.fetchProfile(user.uid);
    if (profile == null) return null;
    // Password-signup accounts never had `email` written to Firestore
    // (only the Google sign-in path does that) — Firebase Auth always has
    // it though, so fall back to that rather than showing a blank field.
    if (profile.email != null && profile.email!.isNotEmpty) return profile;
    return profile.copyWith(email: user.email);
  }
}

/// A genuine live listener on the signed-in user's own profile doc (unlike
/// [currentProfileProvider], which is a one-shot fetch re-run only on auth
/// changes or an explicit invalidate) — this is what lets the router notice
/// an admin suspending the account within moments, mid-session, instead of
/// only on the next relaunch. See the router's `redirect` +
/// `refreshListenable`.
@Riverpod(keepAlive: true)
Stream<AppUserProfile?> currentProfileWatch(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(authRepositoryProvider).watchProfile(user.uid);
}

/// A specific user's `users` document by ID — for showing another user's
/// avatar/display name (e.g. a Creator's manually-uploaded photo on the
/// Brand-facing public profile), as opposed to [currentProfileProvider]
/// which is always the signed-in user's own.
@riverpod
Future<AppUserProfile?> appUserProfileById(Ref ref, String userId) {
  return ref.watch(authRepositoryProvider).fetchProfile(userId);
}

/// Holds the data the OTP screen needs, set by whichever screen navigates
/// to it. Deliberately not passed via GoRouter's route `extra` — that gets
/// dropped when the router re-evaluates its redirect guard mid-flow (e.g.
/// the moment phone verification itself changes the signed-in auth state),
/// which crashed the OTP screen's route builder. Provider state survives
/// that; `extra` doesn't.
@Riverpod(keepAlive: true)
class PendingOtp extends _$PendingOtp {
  @override
  OtpVerificationArgs? build() => null;

  void set(OtpVerificationArgs args) => state = args;

  void clear() => state = null;
}

/// Holds the in-progress sign-in [MultiFactorResolver] once
/// [AuthController.signInWithPassword] hits a [FirebaseAuthMultiFactorException]
/// — same "provider state survives router redirects, route `extra` doesn't"
/// reasoning as [PendingOtp].
@Riverpod(keepAlive: true)
class PendingMfaResolver extends _$PendingMfaResolver {
  @override
  MultiFactorResolver? build() => null;

  void set(MultiFactorResolver resolver) => state = resolver;

  void clear() => state = null;
}

/// Drives the auth screens' sign-up/sign-in/verify/Google/sign-out actions
/// and exposes their loading/error state.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signUpWithPassword(email: email, password: password),
    );
  }

  Future<void> resendEmailVerification() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).resendEmailVerification(),
    );
  }

  /// Returns true once the signed-in user's email has been verified.
  Future<bool> checkEmailVerified() async {
    state = const AsyncLoading();
    var verified = false;
    state = await AsyncValue.guard(() async {
      verified = await ref
          .read(authRepositoryProvider)
          .reloadAndCheckEmailVerified();
    });
    return verified;
  }

  /// Returns true if the account has 2FA enabled and a phone challenge is
  /// now pending (see [pendingMfaResolverProvider]) — the caller should
  /// navigate to the MFA challenge screen instead of treating this as
  /// success or failure. [state] is left non-error either way so the login
  /// screen doesn't show a spurious "incorrect password" message.
  Future<bool> signInWithPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithPassword(email: email, password: password);
      state = const AsyncData(null);
      return false;
    } on FirebaseAuthMultiFactorException catch (e) {
      ref.read(pendingMfaResolverProvider.notifier).set(e.resolver);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).sendPasswordResetEmail(email),
    );
  }

  /// Sends the SMS code and returns the `verificationId` needed by
  /// [verifyPhoneOtp]/[linkPhoneCredential]. [link] must match whichever
  /// of those the caller intends to use once the code arrives.
  Future<String?> sendPhoneOtp(String phone, {bool link = false}) async {
    state = const AsyncLoading();
    String? verificationId;
    state = await AsyncValue.guard(() async {
      verificationId = await ref
          .read(authRepositoryProvider)
          .sendPhoneOtp(phone, link: link);
    });
    return verificationId;
  }

  /// Phone-as-primary login — signs in as the phone number's own identity.
  Future<void> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .verifyPhoneOtp(verificationId: verificationId, smsCode: smsCode),
    );
  }

  /// Finishing a signup — attaches the phone to the already-signed-in
  /// account instead of creating a separate phone-only identity.
  Future<void> linkPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .linkPhoneCredential(
            verificationId: verificationId,
            smsCode: smsCode,
          ),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.signInWithGoogle();
      final user = repository.currentUser;
      if (user != null) {
        await repository.ensureProfileDocument(user);
      }
    });
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.signInWithApple();
      final user = repository.currentUser;
      if (user != null) {
        await repository.ensureProfileDocument(user);
      }
    });
  }

  Future<void> ensureProfileDocument() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final user = repository.currentUser;
      if (user == null) {
        throw StateError('No active session to create a profile for.');
      }
      await repository.ensureProfileDocument(user);
    });
  }

  Future<void> chooseRole(
    UserRole role, {
    String? displayName,
    String? phone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw StateError('No active session to assign a role to.');
      }
      await ref
          .read(authRepositoryProvider)
          .setRole(
            userId: user.uid,
            role: role,
            displayName: displayName,
            phone: phone,
          );
      ref.invalidate(currentProfileProvider);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }

  /// Permanently deletes the signed-in user's account — see
  /// [AuthRepository.deleteAccount].
  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).deleteAccount(),
    );
  }

  /// Enforces that logging in from the Creator tab only works for Creator
  /// accounts (and vice versa for Brand) — a given identity always belongs
  /// to exactly one account with one fixed role, so picking the wrong tab
  /// at login shouldn't silently let you in and reroute you; it should
  /// reject the attempt and say so.
  ///
  /// Returns the account's real role if it doesn't match [expected] (after
  /// signing back out), or null if it matches or has no role yet (a
  /// still-incomplete signup, which the normal flow already handles).
  Future<UserRole?> checkRoleMismatch(UserRole expected) async {
    final repository = ref.read(authRepositoryProvider);
    final user = repository.currentUser;
    if (user == null) return null;
    final profile = await repository.fetchProfile(user.uid);
    final actualRole = profile?.role;
    if (actualRole != null && actualRole != expected) {
      await repository.signOut();
      return actualRole;
    }
    return null;
  }

  Future<void> saveCreatorDetails({
    required List<String> languages,
    required List<String> categories,
    required String stateName,
    required String city,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      final user = authRepository.currentUser;
      if (user == null) {
        throw StateError('No active session to save creator details for.');
      }
      final profile = await authRepository.fetchProfile(user.uid);
      await authRepository.saveCreatorDetails(
        userId: user.uid,
        // Deliberately not falling back to a placeholder like 'Creator'
        // here — this gets stored as `creatorProfiles/{uid}.displayName`,
        // which every display spot treats as a real name if non-empty
        // (see `creatorDisplayName()`), permanently overriding the
        // Instagram-name fallback for phone/OTP signups that connect
        // Instagram in the very next onboarding step.
        displayName: profile?.displayName ?? '',
        languages: languages,
        categories: categories,
        stateName: stateName,
        city: city,
      );
    });
  }

  Future<void> completeOnboarding() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw StateError('No active session to complete onboarding for.');
      }
      await ref.read(authRepositoryProvider).completeOnboarding(user.uid);
      ref.invalidate(currentProfileProvider);
    });
  }

  Future<void> acceptTerms() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw StateError('No active session to accept terms for.');
      }
      await ref.read(authRepositoryProvider).acceptTerms(user.uid);
      ref.invalidate(currentProfileProvider);
    });
  }

  Future<void> setPushNotificationsEnabled(bool enabled) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw StateError('No active session to update settings for.');
      }
      await ref
          .read(authRepositoryProvider)
          .setPushNotificationsEnabled(userId: user.uid, enabled: enabled);
      ref.invalidate(currentProfileProvider);
    });
  }

  Future<void> updateDisplayName(String displayName) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw StateError('No active session to update the name for.');
      }
      await ref
          .read(authRepositoryProvider)
          .updateDisplayName(userId: user.uid, displayName: displayName);
      ref.invalidate(currentProfileProvider);
    });
  }

  Future<void> uploadAvatar(File file) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw StateError('No active session to update the avatar for.');
      }
      await ref
          .read(authRepositoryProvider)
          .uploadAvatar(userId: user.uid, file: file);
      ref.invalidate(currentProfileProvider);
    });
  }

  /// Replaces the signed-in user's phone number, once [smsCode] (sent via
  /// [sendPhoneOtp]) has been confirmed.
  Future<void> changePhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .changePhoneNumber(verificationId: verificationId, smsCode: smsCode);
      ref.invalidate(currentProfileProvider);
    });
  }

  /// Sends a verification link to [newEmail] — the caller should show a
  /// "check your inbox" state and poll [checkEmailChangeVerified].
  Future<void> changeEmail(String newEmail) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).changeEmail(newEmail),
    );
  }

  /// Returns true once [newEmail] (from a prior [changeEmail] call) has
  /// actually taken effect on the Firebase Auth account.
  Future<bool> checkEmailChangeVerified(String newEmail) async {
    state = const AsyncLoading();
    var verified = false;
    state = await AsyncValue.guard(() async {
      verified = await ref
          .read(authRepositoryProvider)
          .reloadAndCheckEmailChanged(newEmail);
    });
    return verified;
  }

  /// Re-authenticates with the account's password — call this and retry
  /// after [changePhoneNumber]/[changeEmail] throw `requires-recent-login`.
  Future<void> reauthenticateWithPassword(String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () =>
          ref.read(authRepositoryProvider).reauthenticateWithPassword(password),
    );
  }

  // --- Two-factor authentication (authenticator app / TOTP) ---

  Future<void> resolveMfaSignIn({required String oneTimePassword}) async {
    final resolver = ref.read(pendingMfaResolverProvider);
    if (resolver == null) {
      throw StateError('No pending 2FA challenge to resolve.');
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .resolveMfaSignIn(
            resolver: resolver,
            oneTimePassword: oneTimePassword,
          );
      ref.read(pendingMfaResolverProvider.notifier).clear();
    });
  }
}
