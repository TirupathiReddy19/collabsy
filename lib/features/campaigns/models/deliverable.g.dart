// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deliverable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Deliverable _$DeliverableFromJson(Map<String, dynamic> json) => _Deliverable(
  id: json['id'] as String,
  campaignId: json['campaignId'] as String,
  applicationId: json['applicationId'] as String,
  creatorId: json['creatorId'] as String,
  creatorName: json['creatorName'] as String,
  brandId: json['brandId'] as String,
  status:
      $enumDecodeNullable(_$DeliverableStatusEnumMap, json['status']) ??
      DeliverableStatus.pending,
  submissionNote: json['submissionNote'] as String?,
  submittedAt: const NullableTimestampConverter().fromJson(json['submittedAt']),
  reviewedAt: const NullableTimestampConverter().fromJson(json['reviewedAt']),
);

Map<String, dynamic> _$DeliverableToJson(
  _Deliverable instance,
) => <String, dynamic>{
  'id': instance.id,
  'campaignId': instance.campaignId,
  'applicationId': instance.applicationId,
  'creatorId': instance.creatorId,
  'creatorName': instance.creatorName,
  'brandId': instance.brandId,
  'status': _$DeliverableStatusEnumMap[instance.status]!,
  'submissionNote': instance.submissionNote,
  'submittedAt': const NullableTimestampConverter().toJson(
    instance.submittedAt,
  ),
  'reviewedAt': const NullableTimestampConverter().toJson(instance.reviewedAt),
};

const _$DeliverableStatusEnumMap = {
  DeliverableStatus.pending: 'pending',
  DeliverableStatus.submitted: 'submitted',
  DeliverableStatus.approved: 'approved',
};
