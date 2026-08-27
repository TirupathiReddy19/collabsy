// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      body: json['body'] as String,
      referenceType: json['referenceType'] as String?,
      referenceId: json['referenceId'] as String?,
      read: json['read'] as bool? ?? false,
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$AppNotificationToJson(
  _AppNotification instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'type': _$NotificationTypeEnumMap[instance.type]!,
  'title': instance.title,
  'body': instance.body,
  'referenceType': instance.referenceType,
  'referenceId': instance.referenceId,
  'read': instance.read,
  'createdAt': const NullableTimestampConverter().toJson(instance.createdAt),
};

const _$NotificationTypeEnumMap = {
  NotificationType.newApplication: 'newApplication',
  NotificationType.applicationAccepted: 'applicationAccepted',
  NotificationType.applicationRejected: 'applicationRejected',
  NotificationType.newMessage: 'newMessage',
  NotificationType.deliverableSubmitted: 'deliverableSubmitted',
  NotificationType.deliverableApproved: 'deliverableApproved',
  NotificationType.campaignApproved: 'campaignApproved',
  NotificationType.campaignRejected: 'campaignRejected',
  NotificationType.profileVerified: 'profileVerified',
  NotificationType.profileRejected: 'profileRejected',
  NotificationType.supportReply: 'supportReply',
  NotificationType.applicationWithdrawn: 'applicationWithdrawn',
  NotificationType.welcomeMessage: 'welcomeMessage',
};
