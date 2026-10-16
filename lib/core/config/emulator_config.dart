import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Set at build time with `--dart-define=USE_FIREBASE_EMULATOR=true`. Only
/// the staging build scripts in `staging/` pass this — a normal `flutter
/// build web` (and every production deploy) never does, so this stays
/// `false`, and this whole file is a no-op, in every real build.
const bool useFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

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
