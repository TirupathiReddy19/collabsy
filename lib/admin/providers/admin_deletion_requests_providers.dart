import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';

part 'admin_deletion_requests_providers.g.dart';

typedef DeletionRequest = ({
  String id,
  String identifier,
  String? reason,
  String status,
  DateTime? createdAt,
});

/// Every account-deletion request submitted from the public website's
/// `/delete-account` page, linked from the Play Console Data Safety form —
/// see `lib/website/screens/website_delete_account_screen.dart`. Newest
/// first.
@riverpod
Stream<List<DeletionRequest>> allDeletionRequests(Ref ref) {
  return ref
      .watch(firestoreProvider)
      .collection('accountDeletionRequests')
      .snapshots()
      .map((snapshot) {
        final items = snapshot.docs.map((doc) {
          final data = doc.data();
          final createdAt = data['createdAt'];
          return (
            id: doc.id,
            identifier: data['identifier'] as String? ?? '',
            reason: data['reason'] as String?,
            status: data['status'] as String? ?? 'pending',
            createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
          );
        }).toList();
        items.sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );
        return items;
      });
}

@Riverpod(keepAlive: true)
class AdminDeletionRequestsController
    extends _$AdminDeletionRequestsController {
  @override
  FutureOr<void> build() {}

  Future<void> markProcessed(String requestId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(firestoreProvider)
          .collection('accountDeletionRequests')
          .doc(requestId)
          .update({'status': 'processed'}),
    );
  }
}
