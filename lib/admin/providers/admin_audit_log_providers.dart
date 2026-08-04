import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../models/audit_log.dart';

part 'admin_audit_log_providers.g.dart';

/// The only place that writes to `auditLogs` — every admin decision
/// (campaign/brand approve or reject) calls this right alongside the
/// actual status change, so there's always a permanent record of it.
class AdminAuditLogRepository {
  AdminAuditLogRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> log({
    required String actorEmail,
    required AuditLogAction action,
    required String targetId,
    required String targetName,
  }) {
    return _firestore.collection('auditLogs').add({
      'actorEmail': actorEmail,
      'action': action.toDbValue(),
      'targetId': targetId,
      'targetName': targetName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

@Riverpod(keepAlive: true)
AdminAuditLogRepository adminAuditLogRepository(Ref ref) {
  return AdminAuditLogRepository(ref.watch(firestoreProvider));
}

@riverpod
Stream<List<AuditLogEntry>> allAuditLogs(Ref ref) {
  return ref.watch(firestoreProvider).collection('auditLogs').snapshots().map((
    snapshot,
  ) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['timestamp'];
      return (
        actorEmail: data['actorEmail'] as String? ?? '',
        action: AuditLogAction.fromDbValue(data['action'] as String?),
        targetId: data['targetId'] as String? ?? '',
        targetName: data['targetName'] as String? ?? '',
        timestamp: timestamp is Timestamp ? timestamp.toDate() : null,
      );
    }).toList()..sort(
      (a, b) =>
          (b.timestamp ?? DateTime(0)).compareTo(a.timestamp ?? DateTime(0)),
    );
  });
}
