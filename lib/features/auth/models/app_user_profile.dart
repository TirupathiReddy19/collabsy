import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _AppUserProfile;

  factory AppUserProfile.fromJson(Map<String, dynamic> json) =>
      _$AppUserProfileFromJson(json);
}
