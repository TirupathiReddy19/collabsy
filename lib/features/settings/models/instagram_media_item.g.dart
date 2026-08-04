// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instagram_media_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InstagramMediaItem _$InstagramMediaItemFromJson(Map<String, dynamic> json) =>
    _InstagramMediaItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      mediaUrl: json['mediaUrl'] as String?,
      mediaType: json['mediaType'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      permalink: json['permalink'] as String?,
      caption: json['caption'] as String?,
      timestamp: const NullableTimestampConverter().fromJson(json['timestamp']),
    );

Map<String, dynamic> _$InstagramMediaItemToJson(
  _InstagramMediaItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'mediaUrl': instance.mediaUrl,
  'mediaType': instance.mediaType,
  'thumbnailUrl': instance.thumbnailUrl,
  'permalink': instance.permalink,
  'caption': instance.caption,
  'timestamp': const NullableTimestampConverter().toJson(instance.timestamp),
};
