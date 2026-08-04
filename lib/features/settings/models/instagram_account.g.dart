// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instagram_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InstagramAccount _$InstagramAccountFromJson(
  Map<String, dynamic> json,
) => _InstagramAccount(
  id: json['id'] as String,
  status:
      $enumDecodeNullable(_$InstagramConnectionStatusEnumMap, json['status']) ??
      InstagramConnectionStatus.disconnected,
  instagramUserId: json['instagramUserId'] as String?,
  username: json['username'] as String?,
  name: json['name'] as String?,
  profilePictureUrl: json['profilePictureUrl'] as String?,
  biography: json['biography'] as String?,
  website: json['website'] as String?,
  followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
  followsCount: (json['followsCount'] as num?)?.toInt() ?? 0,
  mediaCount: (json['mediaCount'] as num?)?.toInt() ?? 0,
  connectedAt: const NullableTimestampConverter().fromJson(json['connectedAt']),
  lastSyncedAt: const NullableTimestampConverter().fromJson(
    json['lastSyncedAt'],
  ),
);

Map<String, dynamic> _$InstagramAccountToJson(_InstagramAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$InstagramConnectionStatusEnumMap[instance.status]!,
      'instagramUserId': instance.instagramUserId,
      'username': instance.username,
      'name': instance.name,
      'profilePictureUrl': instance.profilePictureUrl,
      'biography': instance.biography,
      'website': instance.website,
      'followersCount': instance.followersCount,
      'followsCount': instance.followsCount,
      'mediaCount': instance.mediaCount,
      'connectedAt': const NullableTimestampConverter().toJson(
        instance.connectedAt,
      ),
      'lastSyncedAt': const NullableTimestampConverter().toJson(
        instance.lastSyncedAt,
      ),
    };

const _$InstagramConnectionStatusEnumMap = {
  InstagramConnectionStatus.connected: 'connected',
  InstagramConnectionStatus.expired: 'expired',
  InstagramConnectionStatus.revoked: 'revoked',
  InstagramConnectionStatus.disconnected: 'disconnected',
};
