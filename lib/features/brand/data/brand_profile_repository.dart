import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/brand_profile.dart';
import '../../../shared/models/verification_status.dart';

/// The only place in the `brand` feature that talks to the
/// `brandProfiles` Firestore collection directly.
class BrandProfileRepository {
  BrandProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _brandProfiles =>
      _firestore.collection('brandProfiles');

  Future<BrandProfile?> fetchBrandProfile(String userId) async {
    final doc = await _brandProfiles.doc(userId).get();
    if (!doc.exists) return null;
    return BrandProfile.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Live version of [fetchBrandProfile] — used by the brand's own
  /// verification-pending screen so it can notice the moment an admin
  /// approves/rejects them without needing to relaunch the app.
  Stream<BrandProfile?> watchProfile(String userId) {
    return _brandProfiles.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return BrandProfile.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  /// Admin-only — approves or rejects a brand after checking their website
  /// and LinkedIn profile. Never called by the brand's own account.
  Future<void> setVerificationStatus({
    required String userId,
    required VerificationStatus status,
  }) {
    return _brandProfiles.doc(userId).set({
      'verificationStatus': status.toDbValue(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Every brand's profile, unfiltered — for the Admin brands directory.
  Stream<List<BrandProfile>> watchDirectory() {
    return _brandProfiles.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => BrandProfile.fromJson({...doc.data(), 'id': doc.id}))
          .toList(),
    );
  }

  Future<void> updateProfile({
    required String userId,
    String? companyName,
    String? designation,
    String? bio,
    List<String>? categories,
    String? website,
    String? companySize,
    String? linkedinUrl,
    String? state,
    String? city,
  }) async {
    await _brandProfiles.doc(userId).set({
      if (companyName != null) 'companyName': companyName,
      if (designation != null) 'designation': designation,
      if (bio != null) 'bio': bio,
      if (categories != null) 'categories': categories,
      if (website != null) 'website': website,
      if (companySize != null) 'companySize': companySize,
      if (linkedinUrl != null) 'linkedinUrl': linkedinUrl,
      if (state != null) 'state': state,
      if (city != null) 'city': city,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
