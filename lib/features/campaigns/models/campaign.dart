import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/firestore_converters.dart';
import 'campaign_status.dart';
import 'compensation_type.dart';
import 'deliverable_type.dart';

part 'campaign.freezed.dart';
part 'campaign.g.dart';

/// Matches a document in the `campaigns` Firestore collection.
///
/// Every field added after the initial launch (`categories`, `goal`,
/// `targetLocation`, `minFollowers`/`maxFollowers`,
/// `instagramStoryCount`/`instagramPostCount`, `startDate`/`endDate`,
/// `acceptanceMessage`/`rejectionMessage`, `compensationType`,
/// `barterDescription`, `state`, `city`) is nullable or defaulted so
/// campaigns created before that field existed still parse instead of
/// throwing in `fromJson` and breaking the whole list for every campaign.
@freezed
abstract class Campaign with _$Campaign {
  const Campaign._();

  const factory Campaign({
    required String id,
    required String brandId,
    required String brandName,
    required String title,
    required String description,
    @Default(<String>[]) List<String> categories,
    String? goal,
    // Superseded by `targetLocations` (multi-select) — kept only so
    // campaigns created before that existed still parse; new campaigns never
    // write it.
    String? targetLocation,
    @Default(<String>[]) List<String> targetLocations,
    int? minFollowers,
    int? maxFollowers,
    int? creatorsNeeded,
    required DeliverableType deliverableType,
    @Default(0) int instagramStoryCount,
    @Default(0) int instagramPostCount,
    @Default(CompensationType.cash) CompensationType compensationType,
    // Required when `compensationType` is cash; null for barter deals.
    int? budget,
    // Only meaningful when `compensationType` is barter.
    String? barterDescription,
    // The campaign's own location (where the brand/shoot is based) — not
    // to be confused with `targetLocations`, which filters which creators
    // see the campaign.
    String? state,
    String? city,
    @NullableTimestampConverter() DateTime? startDate,
    @NullableTimestampConverter() DateTime? endDate,
    String? acceptanceMessage,
    String? rejectionMessage,
    @Default(CampaignStatus.draft) CampaignStatus status,
    @NullableTimestampConverter() DateTime? createdAt,
    // View tracking, recorded once per creator campaign-detail-screen open
    // (see CampaignsRepository.recordCampaignView). `reach` is the number of
    // distinct creators exposed to the campaign; `engagement` is the total
    // number of times any creator opened its details, repeats included.
    @Default(<String>[]) List<String> viewedByCreatorIds,
    @Default(0) int viewCount,
  }) = _Campaign;

  factory Campaign.fromJson(Map<String, dynamic> json) =>
      _$CampaignFromJson(json);

  int get reach => viewedByCreatorIds.length;

  int get engagement => viewCount;

  String get categoriesLabel =>
      categories.isEmpty ? 'Any category' : categories.join(' · ');

  String get targetLocationsLabel {
    if (targetLocations.isNotEmpty) return targetLocations.join(', ');
    if (targetLocation != null) return targetLocation!;
    return 'All India';
  }

  /// True once [endDate] has passed — a campaign with no [endDate] never
  /// expires. This is the client-side signal that hides an expired
  /// campaign from the Creator browse tab immediately (see
  /// `openCampaigns` in campaigns_providers.dart); the scheduled
  /// `expireCampaigns` Cloud Function is the slower (up to 24h),
  /// authoritative counterpart that actually flips [status] to
  /// [CampaignStatus.expired] so it also drops out of every other
  /// `status == active` query (admin dashboards, etc).
  bool get isExpired => endDate != null && endDate!.isBefore(DateTime.now());

  String get timelineLabel {
    if (startDate == null && endDate == null) return 'No timeline set';
    if (startDate != null && endDate != null) {
      return '${_formatDate(startDate!)} – ${_formatDate(endDate!)}';
    }
    return _formatDate((startDate ?? endDate)!);
  }

  /// The budget entered in the wizard is always per creator — this is the
  /// total across every creator needed, only computable once that count is
  /// known. Null for barter deals (no cash budget at all).
  int? get totalBudget => budget == null || creatorsNeeded == null
      ? null
      : budget! * creatorsNeeded!;

  /// Short chip label for the compensation — "₹500/creator" for cash,
  /// "Barter" for barter deals (the description is shown separately).
  String get compensationLabel => switch (compensationType) {
    CompensationType.barter => 'Barter',
    CompensationType.cash => budget != null ? '₹$budget/creator' : 'Paid',
  };

  String get locationLabel =>
      [city, state].whereType<String>().where((s) => s.isNotEmpty).join(', ');

  String get postedAgoLabel {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return _formatDate(createdAt!);
  }
}

String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
