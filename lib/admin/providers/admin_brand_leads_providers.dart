import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../shared/models/brand_lead.dart';

part 'admin_brand_leads_providers.g.dart';

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

/// Every brand outreach lead across every intern, newest first — the Admin
/// portal's Brand Outreach Leads screen. Interns only ever see their own
/// (see `brand_intern/providers/brand_intern_leads_providers.dart`'s
/// `watchMine`); this is the cross-intern tracking view. Mirrors
/// `admin_leads_providers.dart` exactly.
@riverpod
Stream<List<BrandLead>> allBrandLeads(Ref ref) {
  return ref.watch(firestoreProvider).collection('brandLeads').snapshots().map((
    snapshot,
  ) {
    final leads = snapshot.docs.map(_leadFromDoc).toList()
      ..sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
    return leads;
  });
}
