import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/firestore_converters.dart';
import '../../../shared/models/user_role.dart';

part 'app_user_profile.freezed.dart';
part 'app_user_profile.g.dart';

/// Matches a document in the `users` Firestore collection.
@freezed
abstract class AppUserProfile with _$AppUserProfile {
  const factory AppUserProfile({
    required String id,
    UserRole? role,
    String? displayName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? bio,
    @Default(false) bool onboardingCompleted,
    @Default(true) bool pushNotificationsEnabled,
    String? fcmToken,
    // Null for every account created before this existed — the router's
    // redirect guard treats that exactly like a brand-new signup that
    // hasn't agreed yet, so pre-existing accounts get the same gate on
    // their next app open.
    @NullableTimestampConverter() DateTime? termsAcceptedAt,
    // Only ever written by the `suspendUserAccount`/`reinstateUserAccount`
    // Cloud Functions (Admin SDK) — see `firestore.rules`, which blocks the
    // account owner from setting these on their own writes. Disabling the
    // Firebase Auth user is the real enforcement (it blocks sign-in
    // outright); this is what lets the UI show a real reason instead of a
    // generic error.
    @Default(false) bool suspended,
    String? suspendedReason,
  }) = _AppUserProfile;

  factory AppUserProfile.fromJson(Map<String, dynamic> json) =>
      _$AppUserProfileFromJson(json);
}
