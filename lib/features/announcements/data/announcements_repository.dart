import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/models/announcement.dart';
import '../../../shared/models/user_role.dart';

/// The only place that talks to the `announcements`/`announcementReads`
/// collections directly. Deliberately its own system, not a reuse of
/// `ChatRepository`/`chats` (which requires two real participant ids) — see
/// `SupportChatRepository` for the closer precedent this mirrors: one real
/// user side, with "admin" as the implicit other side, no second uid
/// needed. Unlike notifications, a broadcast is a single shared doc read by
/// everyone in its audience rather than fanned out into a copy per user.
class AnnouncementsRepository {
  AnnouncementsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _announcements =>
      _firestore.collection('announcements');

  DocumentReference<Map<String, dynamic>> _readDoc(String userId) =>
      _firestore.collection('announcementReads').doc(userId);

  /// Every broadcast aimed at [role] (or at everyone), newest first.
  Stream<List<Announcement>> watchForRole(UserRole role) {
    return _announcements
        .where('audience', whereIn: [role.toDbValue(), 'all'])
        .snapshots()
        .map((snapshot) {
          final announcements = snapshot.docs
              .map(
                (doc) => Announcement.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList();
          announcements.sort((a, b) {
            final aTime = a.createdAt ?? DateTime(0);
            final bTime = b.createdAt ?? DateTime(0);
            return bTime.compareTo(aTime);
          });
          return announcements;
        });
  }

  /// Every broadcast across every audience, newest first — the Admin's
  /// "past broadcasts" list.
  Stream<List<Announcement>> watchAll() {
    return _announcements.snapshots().map((snapshot) {
      final announcements = snapshot.docs
          .map((doc) => Announcement.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      announcements.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(0);
        final bTime = b.createdAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
      return announcements;
    });
  }

  /// How many `announcementReads` docs have a `lastReadAt` at or after
  /// [since] (an announcement's `createdAt`) — anyone who opened the
  /// Announcements screen at or after that point has necessarily seen it,
  /// since opening it marks everything up to "now" as read. Uses an
  /// aggregate count query so this never downloads every read doc just to
  /// size them.
  Future<int> countSeenSince(DateTime since) async {
    final snapshot = await _firestore
        .collection('announcementReads')
        .where('lastReadAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// The uids behind [countSeenSince] — who, not just how many, for the
  /// Admin's "who has seen this" list. A doc's own id is the uid, since
  /// `announcementReads` is keyed by user id.
  Future<List<String>> fetchSeenUserIds(DateTime since) async {
    final snapshot = await _firestore
        .collection('announcementReads')
        .where('lastReadAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Stream<DateTime?> watchLastRead(String userId) {
    return _readDoc(userId).snapshots().map((doc) {
      final timestamp = doc.data()?['lastReadAt'] as Timestamp?;
      return timestamp?.toDate();
    });
  }

  Future<void> markRead(String userId) {
    return _readDoc(userId).set({
      'lastReadAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> create({
    required String title,
    required String body,
    required String audience,
    required String createdBy,
    String targetType = 'all',
    List<String>? targetCategories,
    int? targetMinFollowers,
    int? targetMaxFollowers,
    String? targetCreatorId,
    String? targetCreatorName,
    String? targetBrandId,
    String? targetBrandName,
    String? targetCompanySize,
  }) {
    return _announcements.add({
      'title': title,
      'body': body,
      'audience': audience,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'targetType': targetType,
      if (targetCategories != null) 'targetCategories': targetCategories,
      if (targetMinFollowers != null) 'targetMinFollowers': targetMinFollowers,
      if (targetMaxFollowers != null) 'targetMaxFollowers': targetMaxFollowers,
      if (targetCreatorId != null) 'targetCreatorId': targetCreatorId,
      if (targetCreatorName != null) 'targetCreatorName': targetCreatorName,
      if (targetBrandId != null) 'targetBrandId': targetBrandId,
      if (targetBrandName != null) 'targetBrandName': targetBrandName,
      if (targetCompanySize != null) 'targetCompanySize': targetCompanySize,
    });
  }
}
