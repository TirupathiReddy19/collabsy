import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';

part 'campaign_request_providers.g.dart';

/// Matches the `campaignRequests` Firestore rule's `budgetRange in [...]`
/// allow-list exactly — keep the two in sync if this ever changes.
enum CampaignBudgetRange {
  under50k('under_50k', 'Under ₹50,000/mo'),
  fiftyKToTwoL('50k_2l', '₹50,000 – ₹2,00,000/mo'),
  twoLToTenL('2l_10l', '₹2,00,000 – ₹10,00,000/mo'),
  tenLPlus('10l_plus', '₹10,00,000+/mo'),
  notSure('not_sure', 'Not sure yet');

  const CampaignBudgetRange(this.value, this.label);
  final String value;
  final String label;
}

/// Submits the Brands page's "run it for us" managed-campaign form directly
/// to Firestore — same unauthenticated-public-write shape as
/// `accountDeletionRequests` (see
/// `lib/admin/providers/admin_deletion_requests_providers.dart`), enforced
/// by a strict field-allowlist `create` rule rather than a Cloud Function.
@Riverpod(keepAlive: true)
class CampaignRequestController extends _$CampaignRequestController {
  @override
  FutureOr<void> build() {}

  Future<void> submit({
    required String companyName,
    required String contactName,
    required String workEmail,
    required String phone,
    required CampaignBudgetRange budgetRange,
    required String campaignBrief,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(firestoreProvider).collection('campaignRequests').add({
        'companyName': companyName.trim(),
        'contactName': contactName.trim(),
        'workEmail': workEmail.trim(),
        if (phone.trim().isNotEmpty) 'phone': phone.trim(),
        'budgetRange': budgetRange.value,
        'campaignBrief': campaignBrief.trim(),
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
