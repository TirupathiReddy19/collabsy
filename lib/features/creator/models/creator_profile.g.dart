// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreatorProfile _$CreatorProfileFromJson(Map<String, dynamic> json) =>
    _CreatorProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String?,
      bio: json['bio'] as String?,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      languages:
          (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      country: json['country'] as String? ?? 'India',
      state: json['state'] as String?,
      city: json['city'] as String?,
      verificationStatus:
          $enumDecodeNullable(
            _$VerificationStatusEnumMap,
            json['verificationStatus'],
          ) ??
          VerificationStatus.pending,
      gender: $enumDecodeNullable(_$CreatorGenderEnumMap, json['gender']),
      collaborationPreference: $enumDecodeNullable(
        _$CollaborationPreferenceEnumMap,
        json['collaborationPreference'],
      ),
    );

Map<String, dynamic> _$CreatorProfileToJson(_CreatorProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'bio': instance.bio,
      'categories': instance.categories,
      'languages': instance.languages,
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'verificationStatus':
          _$VerificationStatusEnumMap[instance.verificationStatus]!,
      'gender': _$CreatorGenderEnumMap[instance.gender],
      'collaborationPreference':
          _$CollaborationPreferenceEnumMap[instance.collaborationPreference],
    };

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 'pending',
  VerificationStatus.approved: 'approved',
  VerificationStatus.rejected: 'rejected',
};

const _$CreatorGenderEnumMap = {
  CreatorGender.male: 'male',
  CreatorGender.female: 'female',
};

const _$CollaborationPreferenceEnumMap = {
  CollaborationPreference.paid: 'paid',
  CollaborationPreference.barter: 'barter',
  CollaborationPreference.both: 'both',
};
