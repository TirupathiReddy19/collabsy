// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocking_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(blockingRepository)
final blockingRepositoryProvider = BlockingRepositoryProvider._();

final class BlockingRepositoryProvider
    extends
        $FunctionalProvider<
          BlockingRepository,
          BlockingRepository,
          BlockingRepository
        >
    with $Provider<BlockingRepository> {
  BlockingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockingRepositoryHash();

  @$internal
  @override
  $ProviderElement<BlockingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BlockingRepository create(Ref ref) {
    return blockingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BlockingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BlockingRepository>(value),
    );
  }
}

String _$blockingRepositoryHash() =>
    r'7371b5b75789e025e42353374d4b17e0ed8234c2';

/// Everyone the signed-in user has blocked, newest first — feeds the
/// Settings "Blocked accounts" screen.

@ProviderFor(myBlockedUsers)
final myBlockedUsersProvider = MyBlockedUsersProvider._();

/// Everyone the signed-in user has blocked, newest first — feeds the
/// Settings "Blocked accounts" screen.

final class MyBlockedUsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Block>>,
          List<Block>,
          Stream<List<Block>>
        >
    with $FutureModifier<List<Block>>, $StreamProvider<List<Block>> {
  /// Everyone the signed-in user has blocked, newest first — feeds the
  /// Settings "Blocked accounts" screen.
  MyBlockedUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myBlockedUsersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myBlockedUsersHash();

  @$internal
  @override
  $StreamProviderElement<List<Block>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Block>> create(Ref ref) {
    return myBlockedUsers(ref);
  }
}

String _$myBlockedUsersHash() => r'8035b91d842893be09a96d0525247c7c8ee772b0';

/// Whether the signed-in user and [otherId] have a block between them in
/// either direction — feeds the chat-input/menu gating.

@ProviderFor(isBlockedEitherWay)
final isBlockedEitherWayProvider = IsBlockedEitherWayFamily._();

/// Whether the signed-in user and [otherId] have a block between them in
/// either direction — feeds the chat-input/menu gating.

final class IsBlockedEitherWayProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the signed-in user and [otherId] have a block between them in
  /// either direction — feeds the chat-input/menu gating.
  IsBlockedEitherWayProvider._({
    required IsBlockedEitherWayFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isBlockedEitherWayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isBlockedEitherWayHash();

  @override
  String toString() {
    return r'isBlockedEitherWayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isBlockedEitherWay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsBlockedEitherWayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isBlockedEitherWayHash() =>
    r'09804fa6572eda6a9065c3466665874e874eb59d';

/// Whether the signed-in user and [otherId] have a block between them in
/// either direction — feeds the chat-input/menu gating.

final class IsBlockedEitherWayFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  IsBlockedEitherWayFamily._()
    : super(
        retry: null,
        name: r'isBlockedEitherWayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the signed-in user and [otherId] have a block between them in
  /// either direction — feeds the chat-input/menu gating.

  IsBlockedEitherWayProvider call(String otherId) =>
      IsBlockedEitherWayProvider._(argument: otherId, from: this);

  @override
  String toString() => r'isBlockedEitherWayProvider';
}

@ProviderFor(BlockingController)
final blockingControllerProvider = BlockingControllerProvider._();

final class BlockingControllerProvider
    extends $AsyncNotifierProvider<BlockingController, void> {
  BlockingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockingControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockingControllerHash();

  @$internal
  @override
  BlockingController create() => BlockingController();
}

String _$blockingControllerHash() =>
    r'1f2a2a431a2d861499f0b812c40e8e155fbd958b';

abstract class _$BlockingController extends $AsyncNotifier<void> {
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
