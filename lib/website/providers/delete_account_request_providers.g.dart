// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_request_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Submits the website's "Request account deletion" form straight to
/// Firestore — the same `accountDeletionRequests` collection (and rule
/// shape) the old standalone `web-legal/delete-account/` page used, so no
/// rules or Admin-portal changes were needed to move this here. See
/// `lib/admin/providers/admin_deletion_requests_providers.dart` for where
/// staff review these.

@ProviderFor(DeleteAccountRequestController)
final deleteAccountRequestControllerProvider =
    DeleteAccountRequestControllerProvider._();

/// Submits the website's "Request account deletion" form straight to
/// Firestore — the same `accountDeletionRequests` collection (and rule
/// shape) the old standalone `web-legal/delete-account/` page used, so no
/// rules or Admin-portal changes were needed to move this here. See
/// `lib/admin/providers/admin_deletion_requests_providers.dart` for where
/// staff review these.
final class DeleteAccountRequestControllerProvider
    extends $AsyncNotifierProvider<DeleteAccountRequestController, void> {
  /// Submits the website's "Request account deletion" form straight to
  /// Firestore — the same `accountDeletionRequests` collection (and rule
  /// shape) the old standalone `web-legal/delete-account/` page used, so no
  /// rules or Admin-portal changes were needed to move this here. See
  /// `lib/admin/providers/admin_deletion_requests_providers.dart` for where
  /// staff review these.
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
    r'272bd707175404990d493c9cce57158e39ce8b5c';

/// Submits the website's "Request account deletion" form straight to
/// Firestore — the same `accountDeletionRequests` collection (and rule
/// shape) the old standalone `web-legal/delete-account/` page used, so no
/// rules or Admin-portal changes were needed to move this here. See
/// `lib/admin/providers/admin_deletion_requests_providers.dart` for where
/// staff review these.

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
