import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_service.g.dart';

/// Wraps the global [FirebaseAuth.instance] singleton behind a provider so
/// nothing else in the app references it directly.
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) {
  return FirebaseFirestore.instance;
}

@Riverpod(keepAlive: true)
FirebaseStorage firebaseStorage(Ref ref) {
  return FirebaseStorage.instance;
}

@Riverpod(keepAlive: true)
FirebaseFunctions firebaseFunctions(Ref ref) {
  return FirebaseFunctions.instance;
}

@Riverpod(keepAlive: true)
FirebaseAnalytics firebaseAnalytics(Ref ref) {
  return FirebaseAnalytics.instance;
}
