import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/verification_status.dart';
import 'collaboration_preference.dart';
import 'creator_gender.dart';

part 'creator_profile.freezed.dart';
part 'creator_profile.g.dart';

/// Matches a document in the `creatorProfiles` Firestore collection — the
/// creator-only extension of `users/{uid}` (languages/location from
/// post-signup onboarding, plus bio/categories from profile editing).
/// `displayName`/`bio` are denormalized here (not just read from
/// `users/{uid}`) so the Brand-facing directory can list/filter creators
/// from this one collection without joining back to `users`.
@freezed
abstract class CreatorProfile with _$CreatorProfile {
  const factory CreatorProfile({
    required String id,
    String? displayName,
    String? bio,
    @Default([]) List<String> categories,
    @Default([]) List<String> languages,
    @Default('India') String country,
    String? state,
    String? city,
    @Default(VerificationStatus.pending) VerificationStatus verificationStatus,
    // Nullable (no default) is deliberate — a null value is exactly what
    // the router's redirect guard checks to decide whether a creator
    // (brand-new or pre-existing) still needs to be sent through the
    // one-time gender/collaboration-preference gate.
    CreatorGender? gender,
    CollaborationPreference? collaborationPreference,
  }) = _CreatorProfile;

  factory CreatorProfile.fromJson(Map<String, dynamic> json) =>
      _$CreatorProfileFromJson(json);
}
