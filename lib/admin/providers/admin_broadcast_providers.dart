import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/announcements/providers/announcements_providers.dart';
import '../../shared/models/announcement.dart';

part 'admin_broadcast_providers.g.dart';

/// Every broadcast ever sent, newest first — the Admin Broadcast screen's
/// "past broadcasts" list.
@Riverpod(keepAlive: true)
Stream<List<Announcement>> allAnnouncements(Ref ref) {
  return ref.watch(announcementsRepositoryProvider).watchAll();
}

/// How many people have seen a given broadcast — anyone who opened the
/// Announcements screen at or after it was sent. [sentAtMillis] (rather
/// than the `DateTime` itself) keeps this family provider's cache key a
/// plain comparable value.
@riverpod
Future<int> announcementSeenCount(Ref ref, int sentAtMillis) {
  return ref
      .watch(announcementsRepositoryProvider)
      .countSeenSince(DateTime.fromMillisecondsSinceEpoch(sentAtMillis));
}

/// The uids of everyone who has seen a given broadcast — for the "who has
/// seen this" list, opened on demand from the Broadcast screen.
@riverpod
Future<List<String>> announcementSeenUserIds(Ref ref, int sentAtMillis) {
  return ref
      .watch(announcementsRepositoryProvider)
      .fetchSeenUserIds(DateTime.fromMillisecondsSinceEpoch(sentAtMillis));
}
