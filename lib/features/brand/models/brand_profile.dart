import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/verification_status.dart';

part 'brand_profile.freezed.dart';
part 'brand_profile.g.dart';

/// Matches a document in the `brandProfiles` Firestore collection — the
/// brand-only extension of `users/{uid}`. Unlike `creatorProfiles`,
/// `companyName` here is deliberately NOT the same as `users/{uid}.
/// displayName` — that field is the signed-in person's own name (collected
/// at signup), while `companyName` is the brand identity shown to
/// creators throughout the app (campaigns, chat, etc.).
@freezed
abstract class BrandProfile with _$BrandProfile {
  const factory BrandProfile({
    required String id,
    String? companyName,
    String? designation,
    String? bio,
    @Default([]) List<String> categories,
    String? website,
    String? companySize,
    String? linkedinUrl,
    @Default('India') String country,
    String? state,
    String? city,
    @Default(VerificationStatus.pending) VerificationStatus verificationStatus,
  }) = _BrandProfile;

  factory BrandProfile.fromJson(Map<String, dynamic> json) =>
      _$BrandProfileFromJson(json);
}
