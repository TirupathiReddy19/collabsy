// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_request_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Submits the website's "Request account deletion" form through the
/// `submitDeletionRequest` Cloud Function, which validates it and limits how
/// often one visitor can send it. The `accountDeletionRequests` doc it
/// produces is the same one the old direct Firestore write made, so staff
/// still review it the same way — see
/// `lib/admin/providers/admin_deletion_requests_providers.dart`.

@ProviderFor(DeleteAccountRequestController)
final deleteAccountRequestControllerProvider =
    DeleteAccountRequestControllerProvider._();

/// Submits the website's "Request account deletion" form through the
/// `submitDeletionRequest` Cloud Function, which validates it and limits how
/// often one visitor can send it. The `accountDeletionRequests` doc it
/// produces is the same one the old direct Firestore write made, so staff
/// still review it the same way — see
/// `lib/admin/providers/admin_deletion_requests_providers.dart`.
final class DeleteAccountRequestControllerProvider
    extends $AsyncNotifierProvider<DeleteAccountRequestController, void> {
  /// Submits the website's "Request account deletion" form through the
  /// `submitDeletionRequest` Cloud Function, which validates it and limits how
  /// often one visitor can send it. The `accountDeletionRequests` doc it
  /// produces is the same one the old direct Firestore write made, so staff
  /// still review it the same way — see
  /// `lib/admin/providers/admin_deletion_requests_providers.dart`.
  DeleteAccountRequestControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteAccountRequestControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteAccountRequestControllerHash();

  @$internal
  @override
  DeleteAccountRequestController create() => DeleteAccountRequestController();
}

String _$deleteAccountRequestControllerHash() =>
    r'529bd006fad49c5c37c6190bd82de0c793b9a68c';

/// Submits the website's "Request account deletion" form through the
/// `submitDeletionRequest` Cloud Function, which validates it and limits how
/// often one visitor can send it. The `accountDeletionRequests` doc it
/// produces is the same one the old direct Firestore write made, so staff
/// still review it the same way — see
/// `lib/admin/providers/admin_deletion_requests_providers.dart`.

abstract class _$DeleteAccountRequestController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
