import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';

part 'delete_account_request_providers.g.dart';

/// Submits the website's "Request account deletion" form straight to
/// Firestore — the same `accountDeletionRequests` collection (and rule
/// shape) the old standalone `web-legal/delete-account/` page used, so no
/// rules or Admin-portal changes were needed to move this here. See
/// `lib/admin/providers/admin_deletion_requests_providers.dart` for where
/// staff review these.
@Riverpod(keepAlive: true)
class DeleteAccountRequestController extends _$DeleteAccountRequestController {
  @override
  FutureOr<void> build() {}

  Future<void> submit({
    required String identifier,
    required String reason,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(firestoreProvider)
          .collection('accountDeletionRequests')
          .add({
            'identifier': identifier.trim(),
            if (reason.trim().isNotEmpty) 'reason': reason.trim(),
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
    });
  }
}
