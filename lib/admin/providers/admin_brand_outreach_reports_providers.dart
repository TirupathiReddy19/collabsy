import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import 'admin_role_providers.dart';

part 'admin_brand_outreach_reports_providers.g.dart';

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
