import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/firebase_service.dart';
import '../../../shared/models/announcement.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/utils/announcement_audience.dart';
import '../../auth/providers/auth_providers.dart';
import '../../brand/providers/brand_profile_providers.dart';
import '../../creator/providers/creator_profile_providers.dart';
import '../../settings/providers/instagram_providers.dart';
import '../data/announcements_repository.dart';

part 'announcements_providers.g.dart';

@Riverpod(keepAlive: true)
AnnouncementsRepository announcementsRepository(Ref ref) {
  return AnnouncementsRepository(ref.watch(firestoreProvider));
}

/// Every broadcast aimed at the signed-in user's role — the Messages tab's
/// pinned "Collabsy Team" card and the Announcements screen both watch this.
/// For a Creator, this also narrows down to broadcasts whose audience
/// targeting (category/follower range/specific creator) actually matches
/// them — `watchForRole` only filters by role, so a second, client-side
/// pass is needed for the finer targeting dimensions (same reason Brand
/// Discover's category filter is client-side rather than a Firestore
/// `where`).
@Riverpod(keepAlive: true)
Stream<List<Announcement>> myAnnouncements(Ref ref) {
  final role = ref.watch(currentProfileProvider).value?.role;
  if (role == null) return Stream.value(const []);

  final announcements = ref
      .watch(announcementsRepositoryProvider)
      .watchForRole(role);

  final userId = ref.watch(authRepositoryProvider).currentUser?.uid;
  if (userId == null) return announcements;

  if (role == UserRole.creator) {
    final profile = ref.watch(ownCreatorProfileStreamProvider).value;
    final instagram = ref.watch(ownInstagramAccountProvider).value;
    return announcements.map(
      (list) => list
          .where(
            (a) => matchesAudience(
              targetType: a.targetType,
              targetCategories: a.targetCategories,
              targetMinFollowers: a.targetMinFollowers,
              targetMaxFollowers: a.targetMaxFollowers,
              targetCreatorId: a.targetCreatorId,
              creatorId: userId,
              creatorCategories: profile?.categories ?? const [],
              creatorFollowers: instagram?.followersCount,
            ),
          )
          .toList(),
    );
  }

  if (role == UserRole.brand) {
    final profile = ref.watch(ownBrandProfileStreamProvider).value;
    return announcements.map(
      (list) => list
          .where(
            (a) => matchesBrandAudience(
              targetType: a.targetType,
              targetCategories: a.targetCategories,
              targetCompanySize: a.targetCompanySize,
              targetBrandId: a.targetBrandId,
              brandId: userId,
              brandCategories: profile?.categories ?? const [],
              brandCompanySize: profile?.companySize,
            ),
          )
          .toList(),
    );
  }

  return announcements;
}

@Riverpod(keepAlive: true)
Stream<DateTime?> myAnnouncementsLastRead(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(announcementsRepositoryProvider).watchLastRead(user.uid);
}

/// True when the newest broadcast is newer than the last time this user
/// opened the Announcements screen (or they've never opened it at all).
@riverpod
bool hasUnreadAnnouncements(Ref ref) {
  final announcements = ref.watch(myAnnouncementsProvider).value ?? const [];
  if (announcements.isEmpty) return false;
  final lastRead = ref.watch(myAnnouncementsLastReadProvider).value;
  final latest = announcements.first.createdAt;
  if (latest == null) return false;
  if (lastRead == null) return true;
  return latest.isAfter(lastRead);
}

/// Marks all broadcasts as read — called once the Announcements screen
/// opens.
@Riverpod(keepAlive: true)
class AnnouncementsController extends _$AnnouncementsController {
  @override
  FutureOr<void> build() {}

  Future<void> markRead() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;
    await ref.read(announcementsRepositoryProvider).markRead(user.uid);
  }
}
