// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUserProfile _$AppUserProfileFromJson(Map<String, dynamic> json) =>
    _AppUserProfile(
      id: json['id'] as String,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']),
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      pushNotificationsEnabled:
          json['pushNotificationsEnabled'] as bool? ?? true,
      fcmToken: json['fcmToken'] as String?,
      termsAcceptedAt: const NullableTimestampConverter().fromJson(
        json['termsAcceptedAt'],
      ),
      suspended: json['suspended'] as bool? ?? false,
      suspendedReason: json['suspendedReason'] as String?,
    );

Map<String, dynamic> _$AppUserProfileToJson(_AppUserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$UserRoleEnumMap[instance.role],
      'displayName': instance.displayName,
      'email': instance.email,
      'phone': instance.phone,
      'avatarUrl': instance.avatarUrl,
      'bio': instance.bio,
      'onboardingCompleted': instance.onboardingCompleted,
      'pushNotificationsEnabled': instance.pushNotificationsEnabled,
      'fcmToken': instance.fcmToken,
      'termsAcceptedAt': const NullableTimestampConverter().toJson(
        instance.termsAcceptedAt,
      ),
      'suspended': instance.suspended,
      'suspendedReason': instance.suspendedReason,
    };

const _$UserRoleEnumMap = {
  UserRole.creator: 'creator',
  UserRole.brand: 'brand',
  UserRole.admin: 'admin',
};
