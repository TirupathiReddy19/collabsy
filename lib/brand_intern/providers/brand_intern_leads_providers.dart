import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../shared/models/brand_lead.dart';

part 'brand_intern_leads_providers.g.dart';

DateTime? _asDate(dynamic value) => value is Timestamp ? value.toDate() : null;

BrandLead _leadFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;
  return (
    handle: doc.id,
    linkedinUrl: data['linkedinUrl'] as String? ?? '',
    internId: data['internId'] as String? ?? '',
    internEmail: data['internEmail'] as String? ?? '',
    message: data['message'] as String? ?? '',
    status: data['status'] as String? ?? 'linkGenerated',
    createdAt: _asDate(data['createdAt']),
    clickedAt: _asDate(data['clickedAt']),
    clickCount: data['clickCount'] as int? ?? 0,
    matchedUid: data['matchedUid'] as String?,
    signedUpAt: _asDate(data['signedUpAt']),
    onboardingCompleteAt: _asDate(data['onboardingCompleteAt']),
  );
}

/// The only place that talks to the `brandLeads`/`config` collections
/// directly. Mirrors `InternLeadsRepository` exactly.
class BrandInternLeadsRepository {
  BrandInternLeadsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String handle) =>
      _firestore.collection('brandLeads').doc(handle);

  /// Null when no lead exists for this handle yet — the dedup check.
  Future<BrandLead?> fetch(String handle) async {
    final doc = await _doc(handle).get();
    if (!doc.exists) return null;
    return _leadFromDoc(doc);
  }

  Future<void> create({
    required String handle,
    required String linkedinUrl,
    required String internId,
    required String internEmail,
    required String message,
  }) {
    return _doc(handle).set({
      'linkedinUrl': linkedinUrl,
      'internId': internId,
      'internEmail': internEmail,
      'message': message,
      'status': 'linkGenerated',
      'createdAt': FieldValue.serverTimestamp(),
      'clickCount': 0,
    });
  }

  /// Every lead this intern has personally generated, newest first — not
  /// the cross-intern view (that's the Admin portal's Brand Outreach Leads
  /// screen).
  Stream<List<BrandLead>> watchMine(String internId) {
    return _firestore
        .collection('brandLeads')
        .where('internId', isEqualTo: internId)
        .snapshots()
        .map((snapshot) {
          final leads = snapshot.docs.map(_leadFromDoc).toList()
            ..sort(
              (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
                a.createdAt ?? DateTime(0),
              ),
            );
          return leads;
        });
  }

  Future<Map<String, dynamic>?> fetchConfig() async {
    final doc = await _firestore
        .collection('config')
        .doc('brandOutreachLinks')
        .get();
    return doc.data();
  }
}

@Riverpod(keepAlive: true)
BrandInternLeadsRepository brandInternLeadsRepository(Ref ref) {
  return BrandInternLeadsRepository(ref.watch(firestoreProvider));
}

@Riverpod(keepAlive: true)
Stream<List<BrandLead>> myBrandLeads(Ref ref) {
  final uid = ref.watch(authRepositoryProvider).currentUser?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(brandInternLeadsRepositoryProvider).watchMine(uid);
}

@riverpod
Future<Map<String, dynamic>?> brandOutreachConfig(Ref ref) {
  return ref.watch(brandInternLeadsRepositoryProvider).fetchConfig();
}
