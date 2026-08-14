import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';

part 'admin_campaign_requests_providers.g.dart';

typedef CampaignRequest = ({
  String id,
  String companyName,
  String contactName,
  String workEmail,
  String? phone,
  String budgetRange,
  String campaignBrief,
  String status,
  DateTime? createdAt,
});

/// Every managed-campaign lead submitted from the public marketing
/// website's Brands page — see `lib/website/widgets/campaign_request_form.dart`.
/// Newest first.
@riverpod
Stream<List<CampaignRequest>> allCampaignRequests(Ref ref) {
  return ref
      .watch(firestoreProvider)
      .collection('campaignRequests')
      .snapshots()
      .map((snapshot) {
        final items = snapshot.docs.map((doc) {
          final data = doc.data();
          final createdAt = data['createdAt'];
          return (
            id: doc.id,
            companyName: data['companyName'] as String? ?? '',
            contactName: data['contactName'] as String? ?? '',
            workEmail: data['workEmail'] as String? ?? '',
            phone: data['phone'] as String?,
            budgetRange: data['budgetRange'] as String? ?? 'not_sure',
            campaignBrief: data['campaignBrief'] as String? ?? '',
            status: data['status'] as String? ?? 'new',
            createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
          );
        }).toList();
        items.sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );
        return items;
      });
}

@Riverpod(keepAlive: true)
class AdminCampaignRequestsController
    extends _$AdminCampaignRequestsController {
  @override
  FutureOr<void> build() {}

  Future<void> updateStatus(String requestId, String status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(firestoreProvider)
          .collection('campaignRequests')
          .doc(requestId)
          .update({'status': status}),
    );
  }
}
