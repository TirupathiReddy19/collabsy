import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/firestore_converters.dart';
import 'application_status.dart';

part 'campaign_application.freezed.dart';
part 'campaign_application.g.dart';

/// Matches a document in the `applications` Firestore collection — a
/// creator's application to a brand's campaign. Named `CampaignApplication`
/// rather than `Application` to avoid clashing with Flutter's own
/// `WidgetsBinding`-adjacent `Application` types.
@freezed
abstract class CampaignApplication with _$CampaignApplication {
  const factory CampaignApplication({
    required String id,
    required String campaignId,
    required String campaignTitle,
    required String creatorId,
    required String creatorName,
    required String brandId,
    @Default(ApplicationStatus.pending) ApplicationStatus status,
    @NullableTimestampConverter() DateTime? appliedAt,
    // Snapshot of the campaign's deliverables/budget at the moment the
    // creator applied, so the brand can see exactly what the creator agreed
    // to — even if the campaign's own terms change later.
    String? agreedDeliverablesSummary,
    int? agreedBudget,
  }) = _CampaignApplication;

  factory CampaignApplication.fromJson(Map<String, dynamic> json) =>
      _$CampaignApplicationFromJson(json);
}
