import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../models/staff_login_event.dart';

part 'admin_staff_login_event_providers.g.dart';

/// The only place that writes to `staffLoginEvents` — matches
/// `AdminAuditLogRepository`'s "one repository per collection" convention.
class AdminStaffLoginEventRepository {
  AdminStaffLoginEventRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> logEvent({
    required String uid,
    required String email,
    required String roleName,
    required StaffLoginEventType type,
  }) {
    return _firestore.collection('staffLoginEvents').add({
      'uid': uid,
      'email': email,
      'roleName': roleName,
      'type': type.toDbValue(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

@Riverpod(keepAlive: true)
AdminStaffLoginEventRepository adminStaffLoginEventRepository(Ref ref) {
  return AdminStaffLoginEventRepository(ref.watch(firestoreProvider));
}

/// A single staff account's session history, newest first — sorted
/// client-side (matches `allStaffAccountsProvider`'s own convention) rather
/// than a server-side `.orderBy()`, since that would need a new composite
/// index (`firestore.indexes.json` currently defines none).
@riverpod
Stream<List<StaffLoginEvent>> staffLoginEvents(Ref ref, String uid) {
  return ref
      .watch(firestoreProvider)
      .collection('staffLoginEvents')
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          final timestamp = data['timestamp'];
          return (
            uid: data['uid'] as String? ?? '',
            email: data['email'] as String? ?? '',
            roleName: data['roleName'] as String? ?? '',
            type: StaffLoginEventType.fromDbValue(data['type'] as String?),
            timestamp: timestamp is Timestamp ? timestamp.toDate() : null,
          );
        }).toList()..sort(
          (a, b) => (b.timestamp ?? DateTime(0)).compareTo(
            a.timestamp ?? DateTime(0),
          ),
        );
      });
}
