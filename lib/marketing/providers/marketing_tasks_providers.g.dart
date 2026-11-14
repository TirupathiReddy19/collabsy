// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketing_tasks_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(marketingTasksRepository)
final marketingTasksRepositoryProvider = MarketingTasksRepositoryProvider._();

final class MarketingTasksRepositoryProvider
    extends
        $FunctionalProvider<
          MarketingTasksRepository,
          MarketingTasksRepository,
          MarketingTasksRepository
        >
    with $Provider<MarketingTasksRepository> {
  MarketingTasksRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketingTasksRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketingTasksRepositoryHash();

  @$internal
  @override
  $ProviderElement<MarketingTasksRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MarketingTasksRepository create(Ref ref) {
    return marketingTasksRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarketingTasksRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarketingTasksRepository>(value),
    );
  }
}

String _$marketingTasksRepositoryHash() =>
    r'ff99981a798ac8f6119001bd4763eb321d7f3721';

@ProviderFor(allMarketingTasks)
final allMarketingTasksProvider = AllMarketingTasksProvider._();

final class AllMarketingTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MarketingTask>>,
          List<MarketingTask>,
          Stream<List<MarketingTask>>
        >
    with
        $FutureModifier<List<MarketingTask>>,
        $StreamProvider<List<MarketingTask>> {
  AllMarketingTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allMarketingTasksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allMarketingTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<MarketingTask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MarketingTask>> create(Ref ref) {
    return allMarketingTasks(ref);
  }
}

String _$allMarketingTasksHash() => r'1edb83a7b2ef2b05f9661902bea07208d39bc3a5';

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

@ProviderFor(assignableStaff)
final assignableStaffProvider = AssignableStaffProvider._();

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

final class AssignableStaffProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AssignableStaff>>,
          List<AssignableStaff>,
          Stream<List<AssignableStaff>>
        >
    with
        $FutureModifier<List<AssignableStaff>>,
        $StreamProvider<List<AssignableStaff>> {
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
  AssignableStaffProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assignableStaffProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assignableStaffHash();

  @$internal
  @override
  $StreamProviderElement<List<AssignableStaff>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AssignableStaff>> create(Ref ref) {
    return assignableStaff(ref);
  }
}

String _$assignableStaffHash() => r'5a6f1dbe17abbe7d7f03c4a2aa68af5573a535f5';
