// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String,
  senderId: json['senderId'] as String,
  text: json['text'] as String,
  campaignId: json['campaignId'] as String?,
  sentAt: const NullableTimestampConverter().fromJson(json['sentAt']),
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'text': instance.text,
      'campaignId': instance.campaignId,
      'sentAt': const NullableTimestampConverter().toJson(instance.sentAt),
    };
