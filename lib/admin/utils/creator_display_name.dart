import '../../features/auth/models/app_user_profile.dart';
import '../../features/settings/models/instagram_account.dart';
import '../../shared/utils/creator_display_name.dart' as shared;

/// Falls back to the connected Instagram name when there's no real display
/// name. Shared by the Admin Creators list and the Creator detail screen so
/// the two never disagree about what to call someone.
String creatorDisplayNameFor(AppUserProfile user, InstagramAccount? instagram) {
  return shared.creatorDisplayName(
    user.displayName,
    instagram,
    fallback: 'Unnamed creator',
  );
}
