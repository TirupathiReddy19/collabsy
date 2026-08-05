// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_deletion_requests_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every account-deletion request submitted from the public web page
/// linked from the Play Console Data Safety form — see
/// `web-legal/delete-account/index.html`. Newest first.

@ProviderFor(allDeletionRequests)
final allDeletionRequestsProvider = AllDeletionRequestsProvider._();

/// Every account-deletion request submitted from the public web page
/// linked from the Play Console Data Safety form — see
/// `web-legal/delete-account/index.html`. Newest first.

final class AllDeletionRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DeletionRequest>>,
          List<DeletionRequest>,
          Stream<List<DeletionRequest>>
        >
    with
        $FutureModifier<List<DeletionRequest>>,
        $StreamProvider<List<DeletionRequest>> {
  /// Every account-deletion request submitted from the public web page
  /// linked from the Play Console Data Safety form — see
  /// `web-legal/delete-account/index.html`. Newest first.
  AllDeletionRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allDeletionRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allDeletionRequestsHash();

  @$internal
  @override
  $StreamProviderElement<List<DeletionRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DeletionRequest>> create(Ref ref) {
    return allDeletionRequests(ref);
  }
}

String _$allDeletionRequestsHash() =>
    r'492de5fa732fdebd9343b54ab9564b87539acb96';

@ProviderFor(AdminDeletionRequestsController)
final adminDeletionRequestsControllerProvider =
    AdminDeletionRequestsControllerProvider._();

final class AdminDeletionRequestsControllerProvider
    extends $AsyncNotifierProvider<AdminDeletionRequestsController, void> {
  AdminDeletionRequestsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminDeletionRequestsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminDeletionRequestsControllerHash();

  @$internal
  @override
  AdminDeletionRequestsController create() => AdminDeletionRequestsController();
}

String _$adminDeletionRequestsControllerHash() =>
    r'079e833e3c916574490af57f4eb224e06e8c0cf9';

abstract class _$AdminDeletionRequestsController extends $AsyncNotifier<void> {
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
