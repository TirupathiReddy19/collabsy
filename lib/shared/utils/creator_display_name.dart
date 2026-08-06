import '../../features/settings/models/instagram_account.dart';

/// Prefers the connected Instagram account's real name (then @handle) over
/// [displayName] — the name typed into the onboarding form is free text
/// nobody verifies, while Instagram is the one identity signal on this
/// profile that's actually tied to a real account. [displayName] only
/// surfaces for the rare creator who hasn't connected Instagram yet.
String creatorDisplayName(
  String? displayName,
  InstagramAccount? instagram, {
  String fallback = 'New creator',
}) {
  if (instagram?.name?.isNotEmpty == true) return instagram!.name!;
  if (instagram?.username?.isNotEmpty == true) return '@${instagram!.username}';
  if (displayName?.isNotEmpty == true) return displayName!;
  return fallback;
}
