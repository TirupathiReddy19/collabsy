// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Block _$BlockFromJson(Map<String, dynamic> json) => _Block(
  id: json['id'] as String,
  blockerId: json['blockerId'] as String,
  blockerRole: $enumDecode(_$UserRoleEnumMap, json['blockerRole']),
  blockedId: json['blockedId'] as String,
  blockedRole: $enumDecode(_$UserRoleEnumMap, json['blockedRole']),
  createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$BlockToJson(_Block instance) => <String, dynamic>{
  'id': instance.id,
  'blockerId': instance.blockerId,
  'blockerRole': _$UserRoleEnumMap[instance.blockerRole]!,
  'blockedId': instance.blockedId,
  'blockedRole': _$UserRoleEnumMap[instance.blockedRole]!,
  'createdAt': const NullableTimestampConverter().toJson(instance.createdAt),
};

const _$UserRoleEnumMap = {
  UserRole.creator: 'creator',
  UserRole.brand: 'brand',
  UserRole.admin: 'admin',
};
