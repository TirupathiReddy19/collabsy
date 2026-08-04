import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';
import '../models/notification_type.dart';

/// The only place in the `notifications` feature that talks to Firestore
/// directly. Sorts client-side rather than combining `where(userId)` with
/// `orderBy(createdAt)`, which would need a composite index — same
/// philosophy as every other list query in this app.
class NotificationsRepository {
  NotificationsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  Future<void> create({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    String? referenceType,
    String? referenceId,
  }) {
    return _notifications.add({
      'userId': userId,
      'type': type.toDbValue(),
      'title': title,
      'body': body,
      if (referenceType != null) 'referenceType': referenceType,
      if (referenceId != null) 'referenceId': referenceId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AppNotification>> watchForUser(String userId) {
    return _notifications.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final items = snapshot.docs
          .map((doc) => AppNotification.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      items.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      return items;
    });
  }

  Future<void> markRead(String notificationId) {
    return _notifications.doc(notificationId).update({'read': true});
  }

  Future<void> markAllRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return;
    final batch = _firestore.batch();
    for (final id in notificationIds) {
      batch.update(_notifications.doc(id), {'read': true});
    }
    await batch.commit();
  }
}
