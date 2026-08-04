import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/firestore_converters.dart';
import 'deliverable_status.dart';

part 'deliverable.freezed.dart';
part 'deliverable.g.dart';

/// Matches a document in the `deliverables` Firestore collection — one per
/// accepted application, created the moment a brand accepts a creator so
/// there's somewhere for that creator to submit proof of the content they
/// posted, and for the brand to review it.
@freezed
abstract class Deliverable with _$Deliverable {
  const factory Deliverable({
    required String id,
    required String campaignId,
    required String applicationId,
    required String creatorId,
    required String creatorName,
    required String brandId,
    @Default(DeliverableStatus.pending) DeliverableStatus status,
    String? submissionNote,
    @NullableTimestampConverter() DateTime? submittedAt,
    @NullableTimestampConverter() DateTime? reviewedAt,
  }) = _Deliverable;

  factory Deliverable.fromJson(Map<String, dynamic> json) =>
      _$DeliverableFromJson(json);
}
