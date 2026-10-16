import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Set at build time with `--dart-define=USE_FIREBASE_EMULATOR=true`. Only
/// the staging build scripts in `staging/` pass this — a normal `flutter
/// build web` (and every production deploy) never does, so this stays
/// `false`, and this whole file is a no-op, in every real build.
const bool useFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

/// The fake project id `firebase.staging.json` runs the emulator suite
/// under (`firebase emulators:start --project demo-collabsy`) — the
/// Firebase CLI treats any `demo-`-prefixed id as fully offline. Must match
/// `staging/seed.js`'s `projectId`.
const String _stagingProjectId = 'demo-collabsy';

/// `useFirestoreEmulator`/`useAuthEmulator`/etc. only redirect *where*
/// requests go (host:port) — they don't change *which* project the compiled
/// app talks to, and `firebase_options.dart` has the real project id
/// (`collabsy-mobile-applicaation`) baked in at build time by the
/// FlutterFire CLI. Left alone, the app would query the real project's
/// namespace inside the local emulator — empty, since `staging/seed.js`
/// writes under [_stagingProjectId] — so every read comes back empty and
/// every write 400s. Call this on [DefaultFirebaseOptions.currentPlatform]
/// before `Firebase.initializeApp` to swap in the staging project id; a
/// no-op (returns [base] unchanged) unless [useFirebaseEmulator] is true.
FirebaseOptions emulatorAwareOptions(FirebaseOptions base) {
  if (!useFirebaseEmulator) return base;
  return FirebaseOptions(
    apiKey: base.apiKey,
    appId: base.appId,
    messagingSenderId: base.messagingSenderId,
    projectId: _stagingProjectId,
    authDomain: base.authDomain,
    databaseURL: base.databaseURL,
    storageBucket: base.storageBucket,
    measurementId: base.measurementId,
    trackingId: base.trackingId,
    deepLinkURLScheme: base.deepLinkURLScheme,
    androidClientId: base.androidClientId,
    iosClientId: base.iosClientId,
    iosBundleId: base.iosBundleId,
    appGroupId: base.appGroupId,
  );
}

/// Points every Firebase SDK instance at the local Emulator Suite instead of
/// the real backend — same ports `firebase.staging.json` runs them on (see
/// `staging/README.md`). Called once, right after `Firebase.initializeApp`,
/// from every web target's bootstrap (website/admin/intern/brand_intern;
/// deliberately NOT the mobile app's `app_bootstrap.dart` — the staging
/// setup is web-only). A no-op unless [useFirebaseEmulator] is true, so it's
/// safe to call unconditionally.
void connectToFirebaseEmulatorsIfEnabled() {
  if (!useFirebaseEmulator) return;
  if (!kIsWeb) return; // staging build-only; guards against accidental misuse

  const host = 'localhost';
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseStorage.instance.useStorageEmulator(host, 9199);
  FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
}
