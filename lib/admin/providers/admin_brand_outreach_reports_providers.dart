import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../shared/models/brand_email_send.dart';
import 'admin_role_providers.dart';

part 'admin_brand_outreach_reports_providers.g.dart';

BrandEmailSend _emailSendFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;
  final sentAt = data['sentAt'];
  return (
    id: doc.id,
    internId: data['internId'] as String? ?? '',
    internEmail: data['internEmail'] as String? ?? '',
    type: data['type'] as String? ?? 'bulk',
    campaignId: data['campaignId'] as String?,
    campaignName: data['campaignName'] as String? ?? 'Custom message',
    subject: data['subject'] as String? ?? '',
    recipientCount: data['recipientCount'] as int? ?? 0,
    sentAt: sentAt is Timestamp ? sentAt.toDate() : null,
  );
}

typedef BrandOutreachInternSummary = ({
  String internId,
  String internEmail,
  int linksSent,
  int linksClicked,
  int signedUp,
  int onboarded,
  int prospectsAssigned,
  int prospectsContacted,
  int prospectsBulkEmailed,
});

/// One row per active brand-outreach intern — their personally-generated
/// `BrandLead` funnel (link sent -> clicked -> signed up -> onboarded)
/// alongside their admin-pushed `BrandProspect` pool (assigned -> contacted
/// -> ever included in a bulk send), the only place both funnels are shown
/// together across every intern. `brandProspects` is scoped per intern
/// (`where assignedTo == uid`) rather than reading the whole collection —
/// same reasoning as `AdminBrandProspectsRepository`'s own comment: it can
/// hold 30k+ docs, not something to pull in full for a report. `brandLeads`
/// is read in full since it's one-by-one manually-found links, a much
/// smaller volume.
@riverpod
Future<List<BrandOutreachInternSummary>> brandOutreachInternSummaries(
  Ref ref,
) async {
  final firestore = ref.watch(firestoreProvider);
  final staff = await ref.watch(allStaffAccountsProvider.future);
  final interns = staff.where(
    (s) => s.active && s.permissions['/brand-outreach-leads'] == true,
  );

  final leadsSnapshot = await firestore.collection('brandLeads').get();
  final leadsByIntern = <String, List<Map<String, dynamic>>>{};
  for (final doc in leadsSnapshot.docs) {
    final internId = doc.data()['internId'] as String? ?? '';
    (leadsByIntern[internId] ??= []).add(doc.data());
  }

  final summaries = await Future.wait(
    interns.map((intern) async {
      final leads = leadsByIntern[intern.uid] ?? const [];
      final linksClicked = leads.where((data) {
        final status = data['status'] as String?;
        return status == 'clicked' ||
            status == 'signedUp' ||
            status == 'onboardingComplete';
      }).length;
      final signedUp = leads.where((data) {
        final status = data['status'] as String?;
        return status == 'signedUp' || status == 'onboardingComplete';
      }).length;
      final onboarded = leads
          .where((data) => data['status'] == 'onboardingComplete')
          .length;

      final prospects = await firestore
          .collection('brandProspects')
          .where('assignedTo', isEqualTo: intern.uid)
          .get();
      final prospectsContacted = prospects.docs
          .where((doc) => doc.data()['contacted'] == true)
          .length;
      final prospectsBulkEmailed = prospects.docs
          .where((doc) => doc.data()['massEmailSentAt'] != null)
          .length;

      return (
        internId: intern.uid,
        internEmail: intern.email,
        linksSent: leads.length,
        linksClicked: linksClicked,
        signedUp: signedUp,
        onboarded: onboarded,
        prospectsAssigned: prospects.docs.length,
        prospectsContacted: prospectsContacted,
        prospectsBulkEmailed: prospectsBulkEmailed,
      );
    }),
  );

  summaries.sort((a, b) => a.internEmail.compareTo(b.internEmail));
  return summaries;
}

/// The most recent bulk sends across every intern, newest first — which
/// campaign went out, by whom, to how many people, and when. One doc per
/// send (not per recipient), so this is cheap even over a long history.
@riverpod
Stream<List<BrandEmailSend>> allBrandEmailSends(Ref ref) {
  return ref
      .watch(firestoreProvider)
      .collection('brandEmailSends')
      .orderBy('sentAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(_emailSendFromDoc).toList());
}
