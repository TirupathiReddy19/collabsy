// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator_profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(creatorProfileRepository)
final creatorProfileRepositoryProvider = CreatorProfileRepositoryProvider._();

final class CreatorProfileRepositoryProvider
    extends
        $FunctionalProvider<
          CreatorProfileRepository,
          CreatorProfileRepository,
          CreatorProfileRepository
        >
    with $Provider<CreatorProfileRepository> {
  CreatorProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creatorProfileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creatorProfileRepositoryHash();

  @$internal
  @override
  $ProviderElement<CreatorProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreatorProfileRepository create(Ref ref) {
    return creatorProfileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatorProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatorProfileRepository>(value),
    );
  }
}

String _$creatorProfileRepositoryHash() =>
    r'a042c1607043757b228c794ff0a8fb56c70927fa';

/// The signed-in creator's own `creatorProfiles/{uid}` document.

@ProviderFor(ownCreatorProfile)
final ownCreatorProfileProvider = OwnCreatorProfileProvider._();

/// The signed-in creator's own `creatorProfiles/{uid}` document.

final class OwnCreatorProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<CreatorProfile?>,
          CreatorProfile?,
          FutureOr<CreatorProfile?>
        >
    with $FutureModifier<CreatorProfile?>, $FutureProvider<CreatorProfile?> {
  /// The signed-in creator's own `creatorProfiles/{uid}` document.
  OwnCreatorProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ownCreatorProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ownCreatorProfileHash();

  @$internal
  @override
  $FutureProviderElement<CreatorProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CreatorProfile?> create(Ref ref) {
    return ownCreatorProfile(ref);
  }
}

String _$ownCreatorProfileHash() => r'6f0cd6665e2cda0a6d23d175daa6d48b8e6c70a5';

/// Live version of [ownCreatorProfileProvider] — the verification-pending
/// screen watches this so it can move on the instant an admin decides,
/// rather than requiring an app relaunch to notice.
///
/// Reads the user from [authStateChangesProvider] rather than
/// `authRepositoryProvider.currentUser` — the latter is a plain getter, so
/// watching it doesn't rebuild this provider when auth state actually
/// changes. It would lock in whatever `currentUser` was the first time
/// something read this provider (often null, before login even resolves)
/// and never update again for the rest of the app session, which is
/// exactly the kind of stale read the router's live verification gate
/// depends on this provider NOT being.

@ProviderFor(ownCreatorProfileStream)
final ownCreatorProfileStreamProvider = OwnCreatorProfileStreamProvider._();

/// Live version of [ownCreatorProfileProvider] — the verification-pending
/// screen watches this so it can move on the instant an admin decides,
/// rather than requiring an app relaunch to notice.
///
/// Reads the user from [authStateChangesProvider] rather than
/// `authRepositoryProvider.currentUser` — the latter is a plain getter, so
/// watching it doesn't rebuild this provider when auth state actually
/// changes. It would lock in whatever `currentUser` was the first time
/// something read this provider (often null, before login even resolves)
/// and never update again for the rest of the app session, which is
/// exactly the kind of stale read the router's live verification gate
/// depends on this provider NOT being.

final class OwnCreatorProfileStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<CreatorProfile?>,
          CreatorProfile?,
          Stream<CreatorProfile?>
        >
    with $FutureModifier<CreatorProfile?>, $StreamProvider<CreatorProfile?> {
  /// Live version of [ownCreatorProfileProvider] — the verification-pending
  /// screen watches this so it can move on the instant an admin decides,
  /// rather than requiring an app relaunch to notice.
  ///
  /// Reads the user from [authStateChangesProvider] rather than
  /// `authRepositoryProvider.currentUser` — the latter is a plain getter, so
  /// watching it doesn't rebuild this provider when auth state actually
  /// changes. It would lock in whatever `currentUser` was the first time
  /// something read this provider (often null, before login even resolves)
  /// and never update again for the rest of the app session, which is
  /// exactly the kind of stale read the router's live verification gate
  /// depends on this provider NOT being.
  OwnCreatorProfileStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ownCreatorProfileStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ownCreatorProfileStreamHash();

  @$internal
  @override
  $StreamProviderElement<CreatorProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<CreatorProfile?> create(Ref ref) {
    return ownCreatorProfileStream(ref);
  }
}

String _$ownCreatorProfileStreamHash() =>
    r'dfb69c9acbebf803e8502a51f4ddd4907c6b5445';

/// Every creator profile, for the Brand's Discover directory.

@ProviderFor(creatorDirectory)
final creatorDirectoryProvider = CreatorDirectoryProvider._();

/// Every creator profile, for the Brand's Discover directory.

final class CreatorDirectoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CreatorProfile>>,
          List<CreatorProfile>,
          Stream<List<CreatorProfile>>
        >
    with
        $FutureModifier<List<CreatorProfile>>,
        $StreamProvider<List<CreatorProfile>> {
  /// Every creator profile, for the Brand's Discover directory.
  CreatorDirectoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creatorDirectoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creatorDirectoryHash();

  @$internal
  @override
  $StreamProviderElement<List<CreatorProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CreatorProfile>> create(Ref ref) {
    return creatorDirectory(ref);
  }
}

String _$creatorDirectoryHash() => r'468f994ee20f5f08fa6d787327aa41103ff18e8b';

/// A specific creator's profile, for the Brand-facing public profile view.

@ProviderFor(creatorProfileById)
final creatorProfileByIdProvider = CreatorProfileByIdFamily._();

/// A specific creator's profile, for the Brand-facing public profile view.

final class CreatorProfileByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<CreatorProfile?>,
          CreatorProfile?,
          FutureOr<CreatorProfile?>
        >
    with $FutureModifier<CreatorProfile?>, $FutureProvider<CreatorProfile?> {
  /// A specific creator's profile, for the Brand-facing public profile view.
  CreatorProfileByIdProvider._({
    required CreatorProfileByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'creatorProfileByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creatorProfileByIdHash();

  @override
  String toString() {
    return r'creatorProfileByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CreatorProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CreatorProfile?> create(Ref ref) {
    final argument = this.argument as String;
    return creatorProfileById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CreatorProfileByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creatorProfileByIdHash() =>
    r'c30c7072e7333f9f9c448c09be833519cef39b17';

/// A specific creator's profile, for the Brand-facing public profile view.

final class CreatorProfileByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CreatorProfile?>, String> {
  CreatorProfileByIdFamily._()
    : super(
        retry: null,
        name: r'creatorProfileByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A specific creator's profile, for the Brand-facing public profile view.

  CreatorProfileByIdProvider call(String creatorId) =>
      CreatorProfileByIdProvider._(argument: creatorId, from: this);

  @override
  String toString() => r'creatorProfileByIdProvider';
}

/// Category/state/language filters for the Brand's Discover screen —
/// all multi-select, applied client-side over [creatorDirectoryProvider]'s
/// full list (a creator matches if they have ANY of the selected values
/// for that dimension).

@ProviderFor(DiscoverCategoryFilter)
final discoverCategoryFilterProvider = DiscoverCategoryFilterProvider._();

/// Category/state/language filters for the Brand's Discover screen —
/// all multi-select, applied client-side over [creatorDirectoryProvider]'s
/// full list (a creator matches if they have ANY of the selected values
/// for that dimension).
final class DiscoverCategoryFilterProvider
    extends $NotifierProvider<DiscoverCategoryFilter, Set<String>> {
  /// Category/state/language filters for the Brand's Discover screen —
  /// all multi-select, applied client-side over [creatorDirectoryProvider]'s
  /// full list (a creator matches if they have ANY of the selected values
  /// for that dimension).
  DiscoverCategoryFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverCategoryFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverCategoryFilterHash();

  @$internal
  @override
  DiscoverCategoryFilter create() => DiscoverCategoryFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$discoverCategoryFilterHash() =>
    r'334c8b1a51324c081e7836a379fbc4b192f6803c';

/// Category/state/language filters for the Brand's Discover screen —
/// all multi-select, applied client-side over [creatorDirectoryProvider]'s
/// full list (a creator matches if they have ANY of the selected values
/// for that dimension).

abstract class _$DiscoverCategoryFilter extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(DiscoverStateFilter)
final discoverStateFilterProvider = DiscoverStateFilterProvider._();

final class DiscoverStateFilterProvider
    extends $NotifierProvider<DiscoverStateFilter, Set<String>> {
  DiscoverStateFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverStateFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverStateFilterHash();

  @$internal
  @override
  DiscoverStateFilter create() => DiscoverStateFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$discoverStateFilterHash() =>
    r'3b4149dd8613529fb19ee3e073a0b805b1fe2409';

abstract class _$DiscoverStateFilter extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(DiscoverLanguageFilter)
final discoverLanguageFilterProvider = DiscoverLanguageFilterProvider._();

final class DiscoverLanguageFilterProvider
    extends $NotifierProvider<DiscoverLanguageFilter, Set<String>> {
  DiscoverLanguageFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverLanguageFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverLanguageFilterHash();

  @$internal
  @override
  DiscoverLanguageFilter create() => DiscoverLanguageFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$discoverLanguageFilterHash() =>
    r'b73977b65cc5ae6e8c65c1609964e8202b3706d4';

abstract class _$DiscoverLanguageFilter extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Drives editing the creator's own profile (bio/categories).

@ProviderFor(CreatorProfileController)
final creatorProfileControllerProvider = CreatorProfileControllerProvider._();

/// Drives editing the creator's own profile (bio/categories).
final class CreatorProfileControllerProvider
    extends $AsyncNotifierProvider<CreatorProfileController, void> {
  /// Drives editing the creator's own profile (bio/categories).
  CreatorProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creatorProfileControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creatorProfileControllerHash();

  @$internal
  @override
  CreatorProfileController create() => CreatorProfileController();
}

String _$creatorProfileControllerHash() =>
    r'562ba6e8f5c156b8268e99392364c8c9953e651c';

/// Drives editing the creator's own profile (bio/categories).

abstract class _$CreatorProfileController extends $AsyncNotifier<void> {
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
