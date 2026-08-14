import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../shared/models/lead.dart';

part 'admin_leads_providers.g.dart';

DateTime? _asDate(dynamic value) => value is Timestamp ? value.toDate() : null;

Lead _leadFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;
  return (
    handle: doc.id,
    instagramUrl: data['instagramUrl'] as String? ?? '',
    internId: data['internId'] as String? ?? '',
    internEmail: data['internEmail'] as String? ?? '',
    message: data['message'] as String? ?? '',
    comment: data['comment'] as String? ?? 'looking for collabs check your DM.',
    status: data['status'] as String? ?? 'linkGenerated',
    createdAt: _asDate(data['createdAt']),
    clickedAt: _asDate(data['clickedAt']),
    clickCount: data['clickCount'] as int? ?? 0,
    matchedUid: data['matchedUid'] as String?,
    signedUpAt: _asDate(data['signedUpAt']),
    onboardingCompleteAt: _asDate(data['onboardingCompleteAt']),
    internConfirmedSent: data['internConfirmedSent'] as bool? ?? false,
    internConfirmedSentAt: _asDate(data['internConfirmedSentAt']),
    lastFollowUpSentAt: _asDate(data['lastFollowUpSentAt']),
    followUpCount: data['followUpCount'] as int? ?? 0,
  );
}

/// Every outreach lead across every intern, newest first — the Admin
/// portal's Outreach Leads screen. Interns only ever see their own (see
/// `intern/providers/intern_leads_providers.dart`'s `watchMine`); this is
/// the cross-intern tracking view.
@riverpod
Stream<List<Lead>> allLeads(Ref ref) {
  return ref.watch(firestoreProvider).collection('leads').snapshots().map((
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
