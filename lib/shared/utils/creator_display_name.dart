import '../../features/settings/models/instagram_account.dart';

/// Falls back to the connected Instagram name (not the @handle) when
/// there's no real display name — a phone/OTP signup never collects one,
/// but every creator now has to connect Instagram to get past onboarding,
/// so it's usually the only real identity available for those accounts.
String creatorDisplayName(
  String? displayName,
  InstagramAccount? instagram, {
  String fallback = 'Creator',
}) {
  if (displayName?.isNotEmpty == true) return displayName!;
  if (instagram?.name?.isNotEmpty == true) return instagram!.name!;
  if (instagram?.username?.isNotEmpty == true) return '@${instagram!.username}';
  return fallback;
}
