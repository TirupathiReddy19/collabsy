import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';

part 'campaign_request_providers.g.dart';

/// Matches the `submitCampaignRequest` Cloud Function's `budgetRange`
/// allow-list exactly (`functions/src/publicForms/validation.ts`) — keep the
/// two in sync if this ever changes.
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

/// Submits the Brands page's "run it for us" managed-campaign form through
/// the `submitCampaignRequest` Cloud Function, which validates it and limits
/// how often one visitor can send it. It used to write straight to Firestore
/// with an anonymous `create` rule, which nothing stopped a script flooding.
/// The `campaignRequests` doc it produces is unchanged, so the Admin portal
/// reads it as before.
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
      await ref
          .read(firebaseFunctionsProvider)
          .httpsCallable('submitCampaignRequest')
          .call({
            'companyName': companyName.trim(),
            'contactName': contactName.trim(),
            'workEmail': workEmail.trim(),
            if (phone.trim().isNotEmpty) 'phone': phone.trim(),
            'budgetRange': budgetRange.value,
            'campaignBrief': campaignBrief.trim(),
          });
    });
  }
}
