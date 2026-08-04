// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BrandProfile _$BrandProfileFromJson(Map<String, dynamic> json) =>
    _BrandProfile(
      id: json['id'] as String,
      companyName: json['companyName'] as String?,
      designation: json['designation'] as String?,
      bio: json['bio'] as String?,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      website: json['website'] as String?,
      companySize: json['companySize'] as String?,
      linkedinUrl: json['linkedinUrl'] as String?,
      country: json['country'] as String? ?? 'India',
      state: json['state'] as String?,
      city: json['city'] as String?,
      verificationStatus:
          $enumDecodeNullable(
            _$VerificationStatusEnumMap,
            json['verificationStatus'],
          ) ??
          VerificationStatus.pending,
    );

Map<String, dynamic> _$BrandProfileToJson(_BrandProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyName': instance.companyName,
      'designation': instance.designation,
      'bio': instance.bio,
      'categories': instance.categories,
      'website': instance.website,
      'companySize': instance.companySize,
      'linkedinUrl': instance.linkedinUrl,
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'verificationStatus':
          _$VerificationStatusEnumMap[instance.verificationStatus]!,
    };

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 'pending',
  VerificationStatus.approved: 'approved',
  VerificationStatus.rejected: 'rejected',
};
