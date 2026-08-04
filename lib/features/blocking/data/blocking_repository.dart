import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/models/user_role.dart';
import '../models/block.dart';
import '../models/report_reason.dart';

/// The only place that talks to the `blocks`/`reports` collections
/// directly. Doc ids under `blocks` are always `{blockerId}_{blockedId}` —
/// must be mirrored exactly by `firestore.rules`' `isBlocked()`.
class BlockingRepository {
  BlockingRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _blocks =>
      _firestore.collection('blocks');

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection('reports');

  String _blockDocId(String blockerId, String blockedId) =>
      '${blockerId}_$blockedId';

  Future<void> block({
    required String blockerId,
    required UserRole blockerRole,
    required String blockedId,
    required UserRole blockedRole,
  }) {
    return _blocks.doc(_blockDocId(blockerId, blockedId)).set({
      'blockerId': blockerId,
      'blockerRole': blockerRole.toDbValue(),
      'blockedId': blockedId,
      'blockedRole': blockedRole.toDbValue(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unblock({required String blockerId, required String blockedId}) {
    return _blocks.doc(_blockDocId(blockerId, blockedId)).delete();
  }

  Stream<List<Block>> watchBlockedByMe(String userId) {
    return _blocks.where('blockerId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final items = snapshot.docs
          .map((doc) => Block.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      items.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      return items;
    });
  }

  /// One-shot check for either direction — feeds the chat-input/menu
  /// gating cosmetically; `firestore.rules`' own `isBlocked()` is what
  /// actually enforces this against writes.
  Future<bool> isBlockedEitherWay(String userId, String otherId) async {
    final results = await Future.wait([
      _blocks.doc(_blockDocId(userId, otherId)).get(),
      _blocks.doc(_blockDocId(otherId, userId)).get(),
    ]);
    return results.any((doc) => doc.exists);
  }

  Future<void> report({
    required String reporterId,
    required UserRole reporterRole,
    required String reportedId,
    required UserRole reportedRole,
    String? reportedName,
    required ReportReason reason,
    String? details,
    String? chatId,
  }) {
    return _reports.add({
      'reporterId': reporterId,
      'reporterRole': reporterRole.toDbValue(),
      'reportedId': reportedId,
      'reportedRole': reportedRole.toDbValue(),
      if (reportedName != null) 'reportedName': reportedName,
      'reason': reason.toDbValue(),
      if (details != null) 'details': details,
      if (chatId != null) 'chatId': chatId,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
