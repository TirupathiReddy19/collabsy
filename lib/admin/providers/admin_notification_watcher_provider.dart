import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/brand/providers/brand_profile_providers.dart';
import '../../features/campaigns/models/campaign_status.dart';
import '../../features/campaigns/providers/campaigns_providers.dart';
import '../../features/creator/providers/creator_profile_providers.dart';
import '../../features/support/models/support_chat.dart';
import '../../features/support/models/support_message.dart';
import '../../features/support/providers/support_chat_providers.dart';
import '../../shared/models/verification_status.dart';
import '../services/browser_notification_service.dart';
import 'admin_blocking_providers.dart';

part 'admin_notification_watcher_provider.g.dart';

/// Watches the five admin moderation/review queues — creator profiles,
/// brand profiles, campaigns awaiting approval, support tickets, and
/// reports/blocks — and fires a desktop notification (with a
/// category-specific sound, see [BrowserNotificationService]) for every
/// item that newly needs attention.
///
/// `keepAlive: true` and watched once from `AdminShell` so this runs for
/// as long as an admin/staff member is signed in, across every screen —
/// it never needs to be watched again elsewhere.
@Riverpod(keepAlive: true)
Future<void> adminNotificationWatcher(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  await BrowserNotificationService.requestPermission();

  ref.listen(creatorDirectoryProvider, (previous, next) {
    final pending = next.whenOrNull(
      data: (list) => list
          .where((c) => c.verificationStatus == VerificationStatus.pending)
          .toList(),
    );
    if (pending == null) return;
    _processCategory(
      prefs: prefs,
      category: 'creator',
      items: pending,
      idOf: (c) => c.id,
      titleOf: (_) => 'New creator profile to review',
      bodyOf: (c) => (c.displayName?.isNotEmpty ?? false)
          ? '${c.displayName} submitted their profile for verification.'
          : 'A creator submitted their profile for verification.',
      sound: AdminNotificationSound.creatorProfile,
    );
  }, fireImmediately: true);

  ref.listen(brandDirectoryProvider, (previous, next) {
    final pending = next.whenOrNull(
      data: (list) => list
          .where((b) => b.verificationStatus == VerificationStatus.pending)
          .toList(),
    );
    if (pending == null) return;
    _processCategory(
      prefs: prefs,
      category: 'brand',
      items: pending,
      idOf: (b) => b.id,
      titleOf: (_) => 'New brand profile to review',
      bodyOf: (b) => (b.companyName?.isNotEmpty ?? false)
          ? '${b.companyName} submitted their profile for verification.'
          : 'A brand submitted their profile for verification.',
      sound: AdminNotificationSound.brandProfile,
    );
  }, fireImmediately: true);

  ref.listen(allCampaignsProvider, (previous, next) {
    final pending = next.whenOrNull(
      data: (list) =>
          list.where((c) => c.status == CampaignStatus.underReview).toList(),
    );
    if (pending == null) return;
    _processCategory(
      prefs: prefs,
      category: 'campaign',
      items: pending,
      idOf: (c) => c.id,
      titleOf: (_) => 'Campaign ready for review',
      bodyOf: (c) => '${c.brandName} submitted "${c.title}".',
      sound: AdminNotificationSound.campaignApproval,
    );
  }, fireImmediately: true);

  ref.listen(allSupportChatsProvider, (previous, next) {
    final unread = next.whenOrNull(
      data: (list) => list.where(_isUnreadTicket).toList(),
    );
    if (unread == null) return;
    _processCategory(
      prefs: prefs,
      category: 'support',
      items: unread,
      idOf: (t) => t.id,
      titleOf: (_) => 'New support ticket message',
      bodyOf: (t) => '${t.userName}: ${t.lastMessage ?? 'New message'}',
      sound: AdminNotificationSound.supportTicket,
    );
  }, fireImmediately: true);

  ref.listen(allReportsProvider, (previous, next) {
    final open = next.whenOrNull(
      data: (list) => list.where((r) => r.status == 'open').toList(),
    );
    if (open == null) return;
    _processCategory(
      prefs: prefs,
      category: 'report',
      items: open,
      idOf: (r) => r.id,
      titleOf: (_) => 'New report submitted',
      bodyOf: (r) => '${r.reportedName ?? 'A user'} was reported.',
      sound: AdminNotificationSound.reportOrBlock,
    );
  }, fireImmediately: true);

  ref.listen(allBlocksProvider, (previous, next) {
    final blocks = next.whenOrNull(data: (list) => list);
    if (blocks == null) return;
    _processCategory(
      prefs: prefs,
      category: 'block',
      items: blocks,
      idOf: (b) => b.id,
      titleOf: (_) => 'A user was blocked',
      bodyOf: (_) => 'Someone blocked another user on Collabsy.',
      sound: AdminNotificationSound.reportOrBlock,
    );
  }, fireImmediately: true);
}

bool _isUnreadTicket(SupportChat chat) {
  if (chat.lastMessageSenderRole != SupportSenderRole.user) return false;
  final lastMessageAt = chat.lastMessageAt;
  if (lastMessageAt == null) return false;
  final lastRead = chat.supportLastReadAt;
  return lastRead == null || lastMessageAt.isAfter(lastRead);
}

/// Diffs [items] against the set of ids already notified for [category]
/// (persisted in `SharedPreferences`, i.e. this browser's localStorage) and
/// fires a notification for each one that's newly appeared. The very first
/// time a category is ever seen on this browser, its current backlog is
/// recorded silently rather than firing a notification for every existing
/// item.
Future<void> _processCategory<T>({
  required SharedPreferences prefs,
  required String category,
  required List<T> items,
  required String Function(T) idOf,
  required String Function(T) titleOf,
  required String Function(T) bodyOf,
  required AdminNotificationSound sound,
}) async {
  final initKey = 'admin_notif_init_$category';
  final idsKey = 'admin_notif_seen_$category';
  final seen = (prefs.getStringList(idsKey) ?? const []).toSet();
  final isFirstRun = !(prefs.getBool(initKey) ?? false);

  if (!isFirstRun) {
    for (final item in items) {
      final id = idOf(item);
      if (seen.contains(id)) continue;
      BrowserNotificationService.notify(
        title: titleOf(item),
        body: bodyOf(item),
        sound: sound,
        tag: '$category-$id',
      );
    }
  }

  await prefs.setStringList(idsKey, items.map(idOf).toList());
  if (isFirstRun) await prefs.setBool(initKey, true);
}
