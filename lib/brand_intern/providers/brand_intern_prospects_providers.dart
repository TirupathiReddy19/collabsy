import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../shared/models/brand_prospect.dart';

part 'brand_intern_prospects_providers.g.dart';

DateTime? _asDate(dynamic value) => value is Timestamp ? value.toDate() : null;

BrandProspect _prospectFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;
  return (
    id: doc.id,
    brandName: data['brandName'] as String? ?? '',
    website: data['website'] as String?,
    category: data['category'] as String?,
    rawCategory: data['rawCategory'] as String?,
    location: data['location'] as String?,
    city: data['city'] as String?,
    teamSize: data['teamSize'] as String?,
    igFollowers: data['igFollowers'] as String?,
    monthlyVisits: data['monthlyVisits'] as String?,
    instagramUrl: data['instagramUrl'] as String?,
    linkedinUrl: data['linkedinUrl'] as String?,
    emails: List<String>.from((data['emails'] as List?) ?? const []),
    status: data['status'] as String? ?? 'unassigned',
    assignedTo: data['assignedTo'] as String?,
    assignedToEmail: data['assignedToEmail'] as String?,
    assignedAt: _asDate(data['assignedAt']),
    contacted: data['contacted'] as bool? ?? false,
    contactedAt: _asDate(data['contactedAt']),
  );
}

/// The only place that talks to the `brandProspects` collection from the
/// brand-intern tool's side — a reference list of admin-pushed prospects,
/// never link generation (that's `BrandInternLeadsRepository`).
class BrandInternProspectsRepository {
  BrandInternProspectsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<BrandProspect>> watchMine(String internId) {
    return _firestore
        .collection('brandProspects')
        .where('assignedTo', isEqualTo: internId)
        .snapshots()
        .map((snapshot) {
          final prospects = snapshot.docs.map(_prospectFromDoc).toList()
            ..sort(
              (a, b) => (b.assignedAt ?? DateTime(0)).compareTo(
                a.assignedAt ?? DateTime(0),
              ),
            );
          return prospects;
        });
  }

  /// One-way self-report, mirrors the rules' exact allowed shape: flips
  /// `contacted` false -> true with a server timestamp, nothing else.
  Future<void> markContacted(String prospectId) {
    return _firestore.collection('brandProspects').doc(prospectId).update({
      'contacted': true,
      'contactedAt': FieldValue.serverTimestamp(),
    });
  }
}

@Riverpod(keepAlive: true)
BrandInternProspectsRepository brandInternProspectsRepository(Ref ref) {
  return BrandInternProspectsRepository(ref.watch(firestoreProvider));
}

@Riverpod(keepAlive: true)
Stream<List<BrandProspect>> myBrandProspects(Ref ref) {
  final uid = ref.watch(authRepositoryProvider).currentUser?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(brandInternProspectsRepositoryProvider).watchMine(uid);
}
