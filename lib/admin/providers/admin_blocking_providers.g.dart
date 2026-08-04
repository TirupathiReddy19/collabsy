// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_blocking_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every block relationship on the platform, newest first — read-only,
/// feeds the Trust & Safety "Blocked pairs" section.

@ProviderFor(allBlocks)
final allBlocksProvider = AllBlocksProvider._();

/// Every block relationship on the platform, newest first — read-only,
/// feeds the Trust & Safety "Blocked pairs" section.

final class AllBlocksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Block>>,
          List<Block>,
          Stream<List<Block>>
        >
    with $FutureModifier<List<Block>>, $StreamProvider<List<Block>> {
  /// Every block relationship on the platform, newest first — read-only,
  /// feeds the Trust & Safety "Blocked pairs" section.
  AllBlocksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allBlocksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allBlocksHash();

  @$internal
  @override
  $StreamProviderElement<List<Block>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Block>> create(Ref ref) {
    return allBlocks(ref);
  }
}

String _$allBlocksHash() => r'c5c144753544eaa16e1217e360ca97d973b5b443';

/// Every user report, newest first — feeds the Trust & Safety "Reports
/// queue" section.

@ProviderFor(allReports)
final allReportsProvider = AllReportsProvider._();

/// Every user report, newest first — feeds the Trust & Safety "Reports
/// queue" section.

final class AllReportsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserReport>>,
          List<UserReport>,
          Stream<List<UserReport>>
        >
    with $FutureModifier<List<UserReport>>, $StreamProvider<List<UserReport>> {
  /// Every user report, newest first — feeds the Trust & Safety "Reports
  /// queue" section.
  AllReportsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allReportsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allReportsHash();

  @$internal
  @override
  $StreamProviderElement<List<UserReport>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<UserReport>> create(Ref ref) {
    return allReports(ref);
  }
}

String _$allReportsHash() => r'3937ddda477b0304ca6e901f2461a53686d5ab93';

@ProviderFor(AdminBlockingController)
final adminBlockingControllerProvider = AdminBlockingControllerProvider._();

final class AdminBlockingControllerProvider
    extends $AsyncNotifierProvider<AdminBlockingController, void> {
  AdminBlockingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminBlockingControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminBlockingControllerHash();

  @$internal
  @override
  AdminBlockingController create() => AdminBlockingController();
}

String _$adminBlockingControllerHash() =>
    r'940c9ad00ef46e2c99af1fd967d6ef339d168cbe';

abstract class _$AdminBlockingController extends $AsyncNotifier<void> {
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
