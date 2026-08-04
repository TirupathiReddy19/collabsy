import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/models/verification_status.dart';
import '../models/creator_profile.dart';

/// The only place in the `creator` feature that talks to the
/// `creatorProfiles` Firestore collection directly.
class CreatorProfileRepository {
  CreatorProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _creatorProfiles =>
      _firestore.collection('creatorProfiles');

  Future<CreatorProfile?> fetchCreatorProfile(String userId) async {
    final doc = await _creatorProfiles.doc(userId).get();
    if (!doc.exists) return null;
    return CreatorProfile.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Live version of [fetchCreatorProfile] — used by the creator's own
  /// verification-pending screen so it can notice the moment an admin
  /// approves/rejects them without needing to relaunch the app.
  Stream<CreatorProfile?> watchProfile(String userId) {
    return _creatorProfiles.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CreatorProfile.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  /// Admin-only — approves or rejects a creator after reviewing their
  /// connected Instagram. Never called by the creator's own account.
  Future<void> setVerificationStatus({
    required String userId,
    required VerificationStatus status,
  }) {
    return _creatorProfiles.doc(userId).set({
      'verificationStatus': status.toDbValue(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Every creator's profile, unfiltered — the Brand Discover screen does
  /// its category/state/language filtering client-side rather than via
  /// Firestore `where` clauses. That avoids needing composite indexes
  /// configured up front, which is fine while the creator directory is
  /// small; would need revisiting at real scale.
  Stream<List<CreatorProfile>> watchDirectory() {
    return _creatorProfiles.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => CreatorProfile.fromJson({...doc.data(), 'id': doc.id}))
          .toList(),
    );
  }

  Future<void> updateProfile({
    required String userId,
    String? bio,
    List<String>? categories,
    List<String>? languages,
    String? state,
    String? city,
  }) async {
    await _creatorProfiles.doc(userId).set({
      if (bio != null) 'bio': bio,
      if (categories != null) 'categories': categories,
      if (languages != null) 'languages': languages,
      if (state != null) 'state': state,
      if (city != null) 'city': city,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
