// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SupportChat _$SupportChatFromJson(Map<String, dynamic> json) => _SupportChat(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  userRole: $enumDecode(_$UserRoleEnumMap, json['userRole']),
  status:
      $enumDecodeNullable(_$SupportChatStatusEnumMap, json['status']) ??
      SupportChatStatus.open,
  createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
  lastMessage: json['lastMessage'] as String?,
  lastMessageAt: const NullableTimestampConverter().fromJson(
    json['lastMessageAt'],
  ),
  lastMessageSenderRole: $enumDecodeNullable(
    _$SupportSenderRoleEnumMap,
    json['lastMessageSenderRole'],
  ),
  userLastReadAt: const NullableTimestampConverter().fromJson(
    json['userLastReadAt'],
  ),
  supportLastReadAt: const NullableTimestampConverter().fromJson(
    json['supportLastReadAt'],
  ),
  category: $enumDecodeNullable(
    _$SupportTicketCategoryEnumMap,
    json['category'],
  ),
  internalNotes: json['internalNotes'] as String?,
  internalNotesUpdatedAt: const NullableTimestampConverter().fromJson(
    json['internalNotesUpdatedAt'],
  ),
  internalNotesUpdatedBy: json['internalNotesUpdatedBy'] as String?,
);

Map<String, dynamic> _$SupportChatToJson(
  _SupportChat instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'userRole': _$UserRoleEnumMap[instance.userRole]!,
  'status': _$SupportChatStatusEnumMap[instance.status]!,
  'createdAt': const NullableTimestampConverter().toJson(instance.createdAt),
  'lastMessage': instance.lastMessage,
  'lastMessageAt': const NullableTimestampConverter().toJson(
    instance.lastMessageAt,
  ),
  'lastMessageSenderRole':
      _$SupportSenderRoleEnumMap[instance.lastMessageSenderRole],
  'userLastReadAt': const NullableTimestampConverter().toJson(
    instance.userLastReadAt,
  ),
  'supportLastReadAt': const NullableTimestampConverter().toJson(
    instance.supportLastReadAt,
  ),
  'category': _$SupportTicketCategoryEnumMap[instance.category],
  'internalNotes': instance.internalNotes,
  'internalNotesUpdatedAt': const NullableTimestampConverter().toJson(
    instance.internalNotesUpdatedAt,
  ),
  'internalNotesUpdatedBy': instance.internalNotesUpdatedBy,
};

const _$UserRoleEnumMap = {
  UserRole.creator: 'creator',
  UserRole.brand: 'brand',
  UserRole.admin: 'admin',
};

const _$SupportChatStatusEnumMap = {
  SupportChatStatus.open: 'open',
  SupportChatStatus.resolved: 'resolved',
};

const _$SupportSenderRoleEnumMap = {
  SupportSenderRole.user: 'user',
  SupportSenderRole.support: 'support',
};

const _$SupportTicketCategoryEnumMap = {
  SupportTicketCategory.billing: 'billing',
  SupportTicketCategory.technical: 'technical',
  SupportTicketCategory.account: 'account',
  SupportTicketCategory.campaign: 'campaign',
  SupportTicketCategory.other: 'other',
};
