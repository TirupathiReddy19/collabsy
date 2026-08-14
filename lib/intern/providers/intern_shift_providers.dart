import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../shared/utils/date_key.dart';

part 'intern_shift_providers.g.dart';

/// Writes/reads `internShiftStats` — one doc per intern per day,
/// accumulating seconds spent with the tool's tab actually focused (ticked
/// from `intern_home_screen.dart`'s `WidgetsBindingObserver`). See the
/// matching `firestore.rules` block for the 60s-per-write increment cap.
class InternShiftRepository {
  InternShiftRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String internId, String key) =>
      _firestore.collection('internShiftStats').doc('${internId}_$key');

  Future<void> incrementActiveSeconds({
    required String internId,
    required String internEmail,
    required int seconds,
  }) {
    final key = dateKey(DateTime.now());
    return _doc(internId, key).set({
      'internId': internId,
      'internEmail': internEmail,
      'date': key,
      'activeSeconds': FieldValue.increment(seconds),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<int> watchTodayActiveSeconds(String internId) {
    final key = dateKey(DateTime.now());
    return _doc(internId, key).snapshots().map((doc) {
      return doc.data()?['activeSeconds'] as int? ?? 0;
    });
  }
}

@Riverpod(keepAlive: true)
InternShiftRepository internShiftRepository(Ref ref) {
  return InternShiftRepository(ref.watch(firestoreProvider));
}

@Riverpod(keepAlive: true)
Stream<int> myShiftActiveSecondsToday(Ref ref) {
  final uid = ref.watch(authRepositoryProvider).currentUser?.uid;
  if (uid == null) return Stream.value(0);
  return ref.watch(internShiftRepositoryProvider).watchTodayActiveSeconds(uid);
}
