import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';

part 'delete_account_request_providers.g.dart';

/// Submits the website's "Request account deletion" form through the
/// `submitDeletionRequest` Cloud Function, which validates it and limits how
/// often one visitor can send it. The `accountDeletionRequests` doc it
/// produces is the same one the old direct Firestore write made, so staff
/// still review it the same way — see
/// `lib/admin/providers/admin_deletion_requests_providers.dart`.
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
          .read(firebaseFunctionsProvider)
          .httpsCallable('submitDeletionRequest')
          .call({
            'identifier': identifier.trim(),
            if (reason.trim().isNotEmpty) 'reason': reason.trim(),
          });
    });
  }
}
