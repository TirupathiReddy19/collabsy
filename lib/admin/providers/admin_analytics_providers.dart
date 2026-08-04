import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../shared/models/user_role.dart';

part 'admin_analytics_providers.g.dart';

/// One `users` document's id, role, and signup date — a lightweight raw
/// read (not the full `AppUserProfile` model, which doesn't carry
/// `createdAt`) for the Platform Analytics signups-over-time chart, and
/// [userId]/[role] double as the join key for splitting daily active
/// users by role too.
typedef UserSignup = ({String userId, UserRole? role, DateTime? createdAt});

@riverpod
Stream<List<UserSignup>> allUserSignups(Ref ref) {
  return ref.watch(firestoreProvider).collection('users').snapshots().map((
    snapshot,
  ) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['createdAt'];
      return (
        userId: doc.id,
        role: UserRole.fromDbValue(data['role'] as String?),
        createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
      );
    }).toList();
  });
}

/// One entry per `dailyActivity` doc — a user confirmed active on a given
/// calendar day (see `AuthRepository.recordDailyActivity`). [date] is the
/// raw `yyyyMMdd` string the client wrote, not a [DateTime], since that's
/// exactly what's stored and all the chart needs is to group by it.
typedef DailyActivityEntry = ({String userId, String date});

@riverpod
Stream<List<DailyActivityEntry>> allDailyActivity(Ref ref) {
  return ref
      .watch(firestoreProvider)
      .collection('dailyActivity')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return (
            userId: data['userId'] as String? ?? '',
            date: data['date'] as String? ?? '',
          );
        }).toList();
      });
}
