// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserReport _$UserReportFromJson(Map<String, dynamic> json) => _UserReport(
  id: json['id'] as String,
  reporterId: json['reporterId'] as String,
  reporterRole: $enumDecode(_$UserRoleEnumMap, json['reporterRole']),
  reportedId: json['reportedId'] as String,
  reportedRole: $enumDecode(_$UserRoleEnumMap, json['reportedRole']),
  reportedName: json['reportedName'] as String?,
  reason: $enumDecode(_$ReportReasonEnumMap, json['reason']),
  details: json['details'] as String?,
  chatId: json['chatId'] as String?,
  status: json['status'] as String? ?? 'open',
  createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$UserReportToJson(
  _UserReport instance,
) => <String, dynamic>{
  'id': instance.id,
  'reporterId': instance.reporterId,
  'reporterRole': _$UserRoleEnumMap[instance.reporterRole]!,
  'reportedId': instance.reportedId,
  'reportedRole': _$UserRoleEnumMap[instance.reportedRole]!,
  'reportedName': instance.reportedName,
  'reason': _$ReportReasonEnumMap[instance.reason]!,
  'details': instance.details,
  'chatId': instance.chatId,
  'status': instance.status,
  'createdAt': const NullableTimestampConverter().toJson(instance.createdAt),
};

const _$UserRoleEnumMap = {
  UserRole.creator: 'creator',
  UserRole.brand: 'brand',
  UserRole.admin: 'admin',
};

const _$ReportReasonEnumMap = {
  ReportReason.spam: 'spam',
  ReportReason.harassment: 'harassment',
  ReportReason.inappropriate: 'inappropriate',
  ReportReason.fakeProfile: 'fakeProfile',
  ReportReason.other: 'other',
};
