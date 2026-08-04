// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CampaignApplication _$CampaignApplicationFromJson(Map<String, dynamic> json) =>
    _CampaignApplication(
      id: json['id'] as String,
      campaignId: json['campaignId'] as String,
      campaignTitle: json['campaignTitle'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      brandId: json['brandId'] as String,
      status:
          $enumDecodeNullable(_$ApplicationStatusEnumMap, json['status']) ??
          ApplicationStatus.pending,
      appliedAt: const NullableTimestampConverter().fromJson(json['appliedAt']),
      agreedDeliverablesSummary: json['agreedDeliverablesSummary'] as String?,
      agreedBudget: (json['agreedBudget'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CampaignApplicationToJson(
  _CampaignApplication instance,
) => <String, dynamic>{
  'id': instance.id,
  'campaignId': instance.campaignId,
  'campaignTitle': instance.campaignTitle,
  'creatorId': instance.creatorId,
  'creatorName': instance.creatorName,
  'brandId': instance.brandId,
  'status': _$ApplicationStatusEnumMap[instance.status]!,
  'appliedAt': const NullableTimestampConverter().toJson(instance.appliedAt),
  'agreedDeliverablesSummary': instance.agreedDeliverablesSummary,
  'agreedBudget': instance.agreedBudget,
};

const _$ApplicationStatusEnumMap = {
  ApplicationStatus.pending: 'pending',
  ApplicationStatus.accepted: 'accepted',
  ApplicationStatus.rejected: 'rejected',
  ApplicationStatus.withdrawn: 'withdrawn',
  ApplicationStatus.completed: 'completed',
};
