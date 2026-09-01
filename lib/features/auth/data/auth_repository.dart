import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/utils/validators.dart';
import '../../../shared/models/user_role.dart';
import '../../creator/models/collaboration_preference.dart';
import '../../creator/models/creator_gender.dart';
import '../models/app_user_profile.dart';

/// The only place in the `auth` feature that talks to Firebase directly.
class AuthRepository {
  AuthRepository(this._auth, this._firestore, this._storage, this._functions);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseFunctions _functions;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Records that [userId] was active today — one doc per user per
  /// calendar day (a deterministic id, so calling this more than once on
  /// the same day is harmless) — the only signal Platform Analytics has
  /// for daily active users, since there's no separate analytics SDK.
  Future<void> recordDailyActivity(String userId) {
    final now = DateTime.now();
    final dateKey =
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    return _firestore.collection('dailyActivity').doc('${userId}_$dateKey').set(
      {
        'userId': userId,
        'date': dateKey,
        'timestamp': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Creates the account and emails a verification *link* (opens in a
  /// browser — deliberately not deep-linked back into the app, since that's
  /// exactly the fragile setup we're avoiding). Screens poll
  /// [reloadAndCheckEmailVerified] instead of relying on the link itself.
  Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.sendEmailVerification();
  }

  Future<void> resendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No signed-in user to verify.');
    await user.sendEmailVerification();
  }

  /// Adds an email to an account that doesn't have one yet (a phone-first
  /// signup — see `CompleteProfileScreen`'s `_alreadyVerifiedPhone` case)
  /// and sends a verification link for it. Deliberately `verifyBeforeUpdateEmail`
  /// rather than `updateEmail` + `sendEmailVerification`: it doesn't touch
  /// `currentUser.email`/`emailVerified` at all until the link is actually
  /// clicked, so an unverified email is never silently attached to the
  /// account — the exact same "unverified until confirmed" guarantee the
  /// password-signup path gets from Firebase for free.
  Future<void> verifyBeforeUpdateEmail(String email) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No signed-in user to add an email to.');
    await user.verifyBeforeUpdateEmail(email);
  }

  Future<bool> reloadAndCheckEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Throws [FirebaseAuthMultiFactorException] when the account has 2FA
  /// enabled — the caller (see [AuthController.signInWithPassword]) catches
  /// that and routes to the MFA challenge screen instead of treating it as
  /// a failed sign-in.
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Whether [email] has an account at all — Firebase Auth's own sign-in
  /// error is deliberately ambiguous (`invalid-credential` covers both wrong
  /// password and no such user, to stop email-existence probing), so this
  /// goes through the `checkEmailRegistered` Cloud Function (Admin SDK)
  /// instead. Only call this *after* a sign-in attempt has already failed —
  /// it's for redirecting an unregistered email to signup, not for
  /// pre-checking on every keystroke.
  Future<bool> checkEmailRegistered(String email) async {
    final result = await _functions.httpsCallable('checkEmailRegistered').call(
      {'email': email},
    );
    return result.data['registered'] as bool;
  }

  /// Starts phone verification and returns the `verificationId` needed by
  /// [verifyPhoneOtp]/[linkPhoneCredential] — Firebase's phone auth is
  /// callback-based rather than a single request/response, unlike email.
  ///
  /// [link] must match whichever of [verifyPhoneOtp]/[linkPhoneCredential]
  /// the caller intends to use once the code arrives — it's also needed
  /// here for Android's instant auto-verification path, which can resolve
  /// the credential before the user ever types anything.
  Future<String> sendPhoneOtp(String phone, {bool link = false}) {
    final completer = Completer<String>();
    _auth.verifyPhoneNumber(
      phoneNumber: Validators.toE164(phone),
      verificationCompleted: (credential) async {
        if (link) {
          await _auth.currentUser?.linkWithCredential(credential);
        } else {
          await _auth.signInWithCredential(credential);
        }
      },
      verificationFailed: (e) {
        // The UI only ever shows a generic "Couldn't send the code" message
        // — this is the one place the actual reason (wrong test-number
        // format, quota, reCAPTCHA/Play Integrity failure, etc.) is visible
        // at all, so it's worth printing for whoever's running `flutter run`.
        debugPrint('Phone auth verificationFailed: [${e.code}] ${e.message}');
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (verificationId, resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
    return completer.future;
  }

  /// Signs in AS the phone number's own identity — for phone-as-primary
  /// login, where there's no existing account to attach it to.
  ///
  /// Firebase Phone Auth doesn't distinguish sign-in from sign-up: this
  /// silently creates a brand-new account if [verificationId]'s phone number
  /// has never signed in before. Returns whether that just happened, so a
  /// login attempt on an unregistered number can be redirected into
  /// finishing signup instead of leaving a bare, role-less account behind.
  Future<bool> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await _auth.signInWithCredential(credential);
    return result.additionalUserInfo?.isNewUser ?? false;
  }

  /// Attaches the phone number to the currently signed-in account instead
  /// of signing in as a separate phone-only identity — used when finishing
  /// a signup (email/password or Google) that already has an active
  /// session and just needs its phone verified.
  Future<void> linkPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user to link a phone number to.');
    }
    // On some devices, Android's own instant/automatic phone verification
    // (see `verificationCompleted` above) already links the credential in
    // the background before the user ever gets to type anything — the SMS
    // still arrives and this screen still shows regardless, since nothing
    // here is told that already happened. Re-linking a phone the account
    // already has throws `provider-already-linked`; since the end state
    // (phone verified and attached) is exactly what a successful manual
    // entry would produce anyway, this is a no-op success, not an error.
    if (user.phoneNumber != null) return;
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    try {
      await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code != 'provider-already-linked') rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw StateError('Google sign-in was cancelled.');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  /// Firebase recommends a nonce round-trip for Sign in with Apple: the
  /// raw value goes to Apple (hashed), the raw value again goes to
  /// Firebase, and Firebase checks it against the hash embedded in the
  /// identity token Apple returned — proves the token wasn't intercepted
  /// and replayed from a different sign-in attempt.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  Future<void> signInWithApple() async {
    final rawNonce = _generateNonce();
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: _sha256ofString(rawNonce),
    );
    final oauthCredential = OAuthProvider(
      'apple.com',
    ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);
    await _auth.signInWithCredential(oauthCredential);

    // Apple only ever sends the user's name on the very first authorization
    // for this app — unlike Google, Firebase doesn't auto-populate
    // `user.displayName` from it, so `ensureProfileDocument` (called right
    // after this by the controller) would otherwise snapshot a null name
    // forever. Only set it if nothing's there yet, matching how Google's
    // own federated displayName is treated as already-final.
    final fullName = [
      appleCredential.givenName,
      appleCredential.familyName,
    ].whereType<String>().join(' ').trim();
    if (fullName.isNotEmpty && _auth.currentUser?.displayName == null) {
      await _auth.currentUser?.updateDisplayName(fullName);
      await _auth.currentUser?.reload();
    }
  }

  Future<void> signOut() async {
    // Only touch the Google Sign-In plugin for accounts that actually used
    // it — on Web it requires a configured client ID just to construct,
    // which throws for the password-only accounts (e.g. the Admin portal)
    // that never needed it in the first place.
    final usedGoogle = _auth.currentUser?.providerData.any(
      (p) => p.providerId == 'google.com',
    );
    if (usedGoogle ?? false) {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    }
    await _auth.signOut();
  }

  /// Permanently deletes the signed-in user's account — the in-app path
  /// Apple's App Store guideline 5.1.1(v) requires. Does the actual
  /// deletion (Auth user + this user's own Firestore/Storage docs) via the
  /// `deleteAccount` Cloud Function (Admin SDK, no `requires-recent-login`
  /// constraint the way a client-side `user.delete()` would have); this
  /// just also signs out locally afterward so the app's own auth-state
  /// listener redirects to login immediately rather than waiting for the
  /// next token refresh to notice the account is gone.
  Future<void> deleteAccount() async {
    await _functions.httpsCallable('deleteAccount').call();
    await signOut();
  }

  Future<AppUserProfile?> fetchProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return AppUserProfile.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Live version of [fetchProfile] — a real Firestore listener rather than
  /// a one-shot read, so a change made from outside the app (an admin
  /// suspending this account) reaches the router within moments instead of
  /// waiting for the next relaunch. See `currentProfileWatchProvider`.
  Stream<AppUserProfile?> watchProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUserProfile.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  /// Ensures a `users/{uid}` document exists — Firestore has no
  /// auth-trigger equivalent to our old Postgres trigger, so this runs
  /// client-side right after every sign-in/sign-up.
  Future<void> ensureProfileDocument(User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final doc = await ref.get();
    if (doc.exists) return;
    await ref.set({
      'email': user.email,
      'displayName': user.displayName,
      'onboardingCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<AppUserProfile> setRole({
    required String userId,
    required UserRole role,
    String? displayName,
    String? phone,
  }) async {
    final email = _auth.currentUser?.email;
    final docRef = _firestore.collection('users').doc(userId);
    // This is the first write to `users/{uid}` for password/phone signups
    // (unlike Google sign-in, which goes through `ensureProfileDocument`
    // first) — without checking existence here, those accounts never got
    // a `createdAt` at all, which silently dropped every one of them from
    // anything that charts signups over time.
    final isNewDoc = !(await docRef.get()).exists;
    await docRef.set({
      'role': role.toDbValue(),
      if (displayName != null && displayName.isNotEmpty)
        'displayName': displayName,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      if (isNewDoc) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return (await fetchProfile(userId))!;
  }

  /// Writes the creator-only post-signup details (languages/location) to
  /// their own `creatorProfiles/{uid}` doc, kept separate from the
  /// role-agnostic `users/{uid}` doc. [displayName] is denormalized in here
  /// too so the Brand-facing directory (M4) can list/search creators from
  /// this one collection without joining back to `users/{uid}`.
  Future<void> saveCreatorDetails({
    required String userId,
    required String displayName,
    required List<String> languages,
    required List<String> categories,
    required String stateName,
    required String city,
    required CreatorGender gender,
    required CollaborationPreference collaborationPreference,
  }) async {
    await _firestore.collection('creatorProfiles').doc(userId).set({
      'displayName': displayName,
      'languages': languages,
      'categories': categories,
      'country': 'India',
      'state': stateName,
      'city': city,
      'gender': gender.toDbValue(),
      'collaborationPreference': collaborationPreference.toDbValue(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Marks the post-signup onboarding (creator details + Instagram
  /// connect/skip) as finished — the router won't route past it otherwise.
  Future<void> completeOnboarding(String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'onboardingCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Records that this account has accepted the Terms of Service and
  /// Privacy Policy — checked once, on every account, by the router's
  /// redirect guard (see [TermsGateScreen]).
  Future<void> acceptTerms(String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'termsAcceptedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setPushNotificationsEnabled({
    required String userId,
    required bool enabled,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'pushNotificationsEnabled': enabled,
    }, SetOptions(merge: true));
  }

  Future<void> updateDisplayName({
    required String userId,
    required String displayName,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'displayName': displayName,
    }, SetOptions(merge: true));
  }

  /// Saves the device's current FCM token so the push-sending Cloud
  /// Function knows where to deliver this user's notifications.
  Future<void> saveFcmToken({required String userId, required String token}) {
    return _firestore.collection('users').doc(userId).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }

  /// Uploads [file] as the user's avatar (overwriting any previous one at
  /// the same path) and saves the resulting download URL onto their
  /// `users/{userId}` document. Returns the new URL.
  Future<String> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    final ref = _storage.ref('avatars/$userId');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    final url = await ref.getDownloadURL();
    await _firestore.collection('users').doc(userId).set({
      'avatarUrl': url,
    }, SetOptions(merge: true));
    return url;
  }

  /// Replaces the signed-in user's phone number — distinct from
  /// [linkPhoneCredential] (which only works when they have no phone
  /// credential yet); this overwrites an existing one. Security-sensitive:
  /// may throw a `requires-recent-login` [FirebaseAuthException] if the
  /// session is stale, which the caller should handle by re-authenticating
  /// (see [reauthenticateWithPassword]) and retrying.
  Future<void> changePhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user to update a phone number for.');
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await user.updatePhoneNumber(credential);
    await _firestore.collection('users').doc(user.uid).set({
      'phone': user.phoneNumber,
    }, SetOptions(merge: true));
  }

  /// Sends a verification link to [newEmail] — Firebase only actually
  /// updates `user.email` once that link is clicked, so Firestore's
  /// `email` field is deliberately left untouched here. Call
  /// [reloadAndCheckEmailChanged] once the user says they've clicked it.
  /// Same `requires-recent-login` caveat as [changePhoneNumber].
  Future<void> changeEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user to update an email for.');
    }
    await user.verifyBeforeUpdateEmail(newEmail);
  }

  /// Re-checks Firebase Auth's email against [expectedEmail] after the user
  /// claims to have clicked the verification link sent by [changeEmail],
  /// syncing Firestore once it actually matches.
  Future<bool> reloadAndCheckEmailChanged(String expectedEmail) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    final current = _auth.currentUser?.email;
    if (current != expectedEmail) return false;
    await _firestore.collection('users').doc(user.uid).set({
      'email': current,
    }, SetOptions(merge: true));
    return true;
  }

  /// Re-authenticates with the account's password — needed when
  /// [changePhoneNumber]/[changeEmail] throw `requires-recent-login`.
  Future<void> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw StateError('No signed-in email/password user to re-authenticate.');
    }
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  // --- Two-factor authentication (authenticator app / TOTP as a second
  // factor) ---
  //
  // Firebase's multi-factor auth is a genuinely separate mechanism from the
  // phone-as-primary-login flow above: verifying here always goes through a
  // MultiFactorResolver. There's no in-app enrollment path (that UI was
  // built and removed — never reachable from any screen); this only
  // resolves sign-in for an account manually MFA-enrolled via Firebase
  // Console.

  /// Finishes the sign-in [resolver] was blocking on, using the current
  /// code from the user's authenticator app — nothing is "sent" for TOTP.
  Future<UserCredential> resolveMfaSignIn({
    required MultiFactorResolver resolver,
    required String oneTimePassword,
  }) async {
    final hint = resolver.hints.first;
    final assertion = await TotpMultiFactorGenerator.getAssertionForSignIn(
      hint.uid,
      oneTimePassword,
    );
    return resolver.resolveSignIn(assertion);
  }
}
