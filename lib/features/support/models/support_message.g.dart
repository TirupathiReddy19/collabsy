// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SupportMessage _$SupportMessageFromJson(Map<String, dynamic> json) =>
    _SupportMessage(
      id: json['id'] as String,
      senderRole: $enumDecode(_$SupportSenderRoleEnumMap, json['senderRole']),
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
      sentAt: const NullableTimestampConverter().fromJson(json['sentAt']),
    );

Map<String, dynamic> _$SupportMessageToJson(_SupportMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderRole': _$SupportSenderRoleEnumMap[instance.senderRole]!,
      'text': instance.text,
      'imageUrl': instance.imageUrl,
      'sentAt': const NullableTimestampConverter().toJson(instance.sentAt),
    };

const _$SupportSenderRoleEnumMap = {
  SupportSenderRole.user: 'user',
  SupportSenderRole.support: 'support',
};
