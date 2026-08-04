// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Chat _$ChatFromJson(Map<String, dynamic> json) => _Chat(
  id: json['id'] as String,
  creatorId: json['creatorId'] as String,
  creatorName: json['creatorName'] as String,
  brandId: json['brandId'] as String,
  brandName: json['brandName'] as String,
  status:
      $enumDecodeNullable(_$ChatStatusEnumMap, json['status']) ??
      ChatStatus.request,
  lastMessage: json['lastMessage'] as String?,
  lastMessageAt: const NullableTimestampConverter().fromJson(
    json['lastMessageAt'],
  ),
  creatorLastReadAt: const NullableTimestampConverter().fromJson(
    json['creatorLastReadAt'],
  ),
  brandLastReadAt: const NullableTimestampConverter().fromJson(
    json['brandLastReadAt'],
  ),
);

Map<String, dynamic> _$ChatToJson(_Chat instance) => <String, dynamic>{
  'id': instance.id,
  'creatorId': instance.creatorId,
  'creatorName': instance.creatorName,
  'brandId': instance.brandId,
  'brandName': instance.brandName,
  'status': _$ChatStatusEnumMap[instance.status]!,
  'lastMessage': instance.lastMessage,
  'lastMessageAt': const NullableTimestampConverter().toJson(
    instance.lastMessageAt,
  ),
  'creatorLastReadAt': const NullableTimestampConverter().toJson(
    instance.creatorLastReadAt,
  ),
  'brandLastReadAt': const NullableTimestampConverter().toJson(
    instance.brandLastReadAt,
  ),
};

const _$ChatStatusEnumMap = {
  ChatStatus.request: 'request',
  ChatStatus.active: 'active',
};
