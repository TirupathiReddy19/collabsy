import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../shared/models/marketing_task.dart';

part 'marketing_tasks_providers.g.dart';

DateTime? _asDate(dynamic value) => value is Timestamp ? value.toDate() : null;

MarketingTask _taskFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;
  return (
    id: doc.id,
    title: data['title'] as String? ?? '',
    description: data['description'] as String? ?? '',
    assigneeId: data['assigneeId'] as String? ?? '',
    assigneeEmail: data['assigneeEmail'] as String? ?? '',
    status: data['status'] as String? ?? 'todo',
    targetCount: data['targetCount'] as int?,
    currentCount: data['currentCount'] as int?,
    dueDate: _asDate(data['dueDate']),
    createdBy: data['createdBy'] as String? ?? '',
    createdAt: _asDate(data['createdAt']),
    updatedAt: _asDate(data['updatedAt']),
  );
}

/// The only place that talks to the `marketingTasks` collection — every
/// task on the board, admin and staff alike (`firestore.rules` is what
/// actually restricts who can write what; this repository itself has no
/// opinion). Small, bursty collection (one small team's daily tickets),
/// so a live `snapshots()` listener over the whole thing is fine — no
/// "scope per uid" concern like the 30k-doc `brandProspects` pool.
class MarketingTasksRepository {
  MarketingTasksRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<MarketingTask>> watchAll() {
    return _firestore.collection('marketingTasks').snapshots().map((
      snapshot,
    ) {
      final tasks = snapshot.docs.map(_taskFromDoc).toList()
        ..sort(
          (a, b) =>
              (a.dueDate ?? DateTime(9999)).compareTo(b.dueDate ?? DateTime(9999)),
        );
      return tasks;
    });
  }

  /// Admin only — creates a new ticket, always starting `status: 'todo'`.
  Future<void> create({
    required String title,
    required String description,
    required String assigneeId,
    required String assigneeEmail,
    required String createdBy,
    int? targetCount,
    DateTime? dueDate,
  }) {
    return _firestore.collection('marketingTasks').add({
      'title': title,
      'description': description,
      'assigneeId': assigneeId,
      'assigneeEmail': assigneeEmail,
      'status': 'todo',
      'targetCount': targetCount,
      'currentCount': targetCount == null ? null : 0,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate),
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Admin only — edits any field except `status`/`currentCount`, which
  /// are the assignee's own to touch via [updateProgress].
  Future<void> edit({
    required String taskId,
    required String title,
    required String description,
    required String assigneeId,
    required String assigneeEmail,
    int? targetCount,
    DateTime? dueDate,
  }) {
    return _firestore.collection('marketingTasks').doc(taskId).update({
      'title': title,
      'description': description,
      'assigneeId': assigneeId,
      'assigneeEmail': assigneeEmail,
      'targetCount': targetCount,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// The assignee's own update — matches `firestore.rules`' exact allowed
  /// shape (status/currentCount/updatedAt, nothing else).
  Future<void> updateProgress({
    required String taskId,
    required String status,
    int? currentCount,
  }) {
    return _firestore.collection('marketingTasks').doc(taskId).update({
      'status': status,
      if (currentCount != null) 'currentCount': currentCount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String taskId) {
    return _firestore.collection('marketingTasks').doc(taskId).delete();
  }
}

@Riverpod(keepAlive: true)
MarketingTasksRepository marketingTasksRepository(Ref ref) {
  return MarketingTasksRepository(ref.watch(firestoreProvider));
}

@Riverpod(keepAlive: true)
Stream<List<MarketingTask>> allMarketingTasks(Ref ref) {
  return ref.watch(marketingTasksRepositoryProvider).watchAll();
}

typedef AssignableStaff = ({String uid, String email});

/// Every active staff account, for the "assign to" picker in the
/// create/edit task dialog — admin-only UI, but this itself is just a
/// read, so no extra gating needed beyond `marketingTasks`' own rules
/// (any active staff can already read `staffAccounts/{uid}` for
/// themselves; this is the one place in this module that needs every
/// account's email, which `firestore.rules`' `users/{userId}`-style "any
/// authenticated user can read" shape doesn't cover for `staffAccounts` —
/// so this list is scoped to admin in practice via the screen itself, not
/// a rules change, matching how `AdminBrandProspectsScreen` already picks
/// interns from the client-filtered list of staffAccounts.
@riverpod
Stream<List<AssignableStaff>> assignableStaff(Ref ref) {
  return ref
      .watch(firestoreProvider)
      .collection('staffAccounts')
      .where('active', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
        final staff = snapshot.docs
            .map(
              (doc) => (
                uid: doc.id,
                email: doc.data()['email'] as String? ?? doc.id,
              ),
            )
            .toList()
          ..sort((a, b) => a.email.compareTo(b.email));
        return staff;
      });
}
