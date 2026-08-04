// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Announcement _$AnnouncementFromJson(Map<String, dynamic> json) =>
    _Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      audience: json['audience'] as String,
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
      createdBy: json['createdBy'] as String?,
      targetType: json['targetType'] as String? ?? 'all',
      targetCategories: (json['targetCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      targetMinFollowers: (json['targetMinFollowers'] as num?)?.toInt(),
      targetMaxFollowers: (json['targetMaxFollowers'] as num?)?.toInt(),
      targetCreatorId: json['targetCreatorId'] as String?,
      targetCreatorName: json['targetCreatorName'] as String?,
      targetBrandId: json['targetBrandId'] as String?,
      targetBrandName: json['targetBrandName'] as String?,
      targetCompanySize: json['targetCompanySize'] as String?,
    );

Map<String, dynamic> _$AnnouncementToJson(
  _Announcement instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
  'audience': instance.audience,
  'createdAt': const NullableTimestampConverter().toJson(instance.createdAt),
  'createdBy': instance.createdBy,
  'targetType': instance.targetType,
  'targetCategories': instance.targetCategories,
  'targetMinFollowers': instance.targetMinFollowers,
  'targetMaxFollowers': instance.targetMaxFollowers,
  'targetCreatorId': instance.targetCreatorId,
  'targetCreatorName': instance.targetCreatorName,
  'targetBrandId': instance.targetBrandId,
  'targetBrandName': instance.targetBrandName,
  'targetCompanySize': instance.targetCompanySize,
};
