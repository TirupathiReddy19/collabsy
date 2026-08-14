// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Campaign _$CampaignFromJson(Map<String, dynamic> json) => _Campaign(
  id: json['id'] as String,
  brandId: json['brandId'] as String,
  brandName: json['brandName'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  goal: json['goal'] as String?,
  targetLocation: json['targetLocation'] as String?,
  targetLocations:
      (json['targetLocations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  minFollowers: (json['minFollowers'] as num?)?.toInt(),
  maxFollowers: (json['maxFollowers'] as num?)?.toInt(),
  creatorsNeeded: (json['creatorsNeeded'] as num?)?.toInt(),
  deliverableType: $enumDecode(
    _$DeliverableTypeEnumMap,
    json['deliverableType'],
  ),
  instagramStoryCount: (json['instagramStoryCount'] as num?)?.toInt() ?? 0,
  instagramPostCount: (json['instagramPostCount'] as num?)?.toInt() ?? 0,
  compensationType:
      $enumDecodeNullable(
        _$CompensationTypeEnumMap,
        json['compensationType'],
      ) ??
      CompensationType.cash,
  budget: (json['budget'] as num?)?.toInt(),
  barterDescription: json['barterDescription'] as String?,
  state: json['state'] as String?,
  city: json['city'] as String?,
  startDate: const NullableTimestampConverter().fromJson(json['startDate']),
  endDate: const NullableTimestampConverter().fromJson(json['endDate']),
  acceptanceMessage: json['acceptanceMessage'] as String?,
  rejectionMessage: json['rejectionMessage'] as String?,
  status:
      $enumDecodeNullable(_$CampaignStatusEnumMap, json['status']) ??
      CampaignStatus.draft,
  createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
  viewedByCreatorIds:
      (json['viewedByCreatorIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CampaignToJson(_Campaign instance) => <String, dynamic>{
  'id': instance.id,
  'brandId': instance.brandId,
  'brandName': instance.brandName,
  'title': instance.title,
  'description': instance.description,
  'categories': instance.categories,
  'goal': instance.goal,
  'targetLocation': instance.targetLocation,
  'targetLocations': instance.targetLocations,
  'minFollowers': instance.minFollowers,
  'maxFollowers': instance.maxFollowers,
  'creatorsNeeded': instance.creatorsNeeded,
  'deliverableType': _$DeliverableTypeEnumMap[instance.deliverableType]!,
  'instagramStoryCount': instance.instagramStoryCount,
  'instagramPostCount': instance.instagramPostCount,
  'compensationType': _$CompensationTypeEnumMap[instance.compensationType]!,
  'budget': instance.budget,
  'barterDescription': instance.barterDescription,
  'state': instance.state,
  'city': instance.city,
  'startDate': const NullableTimestampConverter().toJson(instance.startDate),
  'endDate': const NullableTimestampConverter().toJson(instance.endDate),
  'acceptanceMessage': instance.acceptanceMessage,
  'rejectionMessage': instance.rejectionMessage,
  'status': _$CampaignStatusEnumMap[instance.status]!,
  'createdAt': const NullableTimestampConverter().toJson(instance.createdAt),
  'viewedByCreatorIds': instance.viewedByCreatorIds,
  'viewCount': instance.viewCount,
};

const _$DeliverableTypeEnumMap = {
  DeliverableType.collabReel: 'collabReel',
  DeliverableType.nonCollab: 'nonCollab',
  DeliverableType.both: 'both',
};

const _$CompensationTypeEnumMap = {
  CompensationType.cash: 'cash',
  CompensationType.barter: 'barter',
};

const _$CampaignStatusEnumMap = {
  CampaignStatus.draft: 'draft',
  CampaignStatus.underReview: 'underReview',
  CampaignStatus.active: 'active',
  CampaignStatus.paused: 'paused',
  CampaignStatus.rejected: 'rejected',
  CampaignStatus.closed: 'closed',
  CampaignStatus.expired: 'expired',
};
