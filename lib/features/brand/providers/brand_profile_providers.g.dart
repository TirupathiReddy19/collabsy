// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(brandProfileRepository)
final brandProfileRepositoryProvider = BrandProfileRepositoryProvider._();

final class BrandProfileRepositoryProvider
    extends
        $FunctionalProvider<
          BrandProfileRepository,
          BrandProfileRepository,
          BrandProfileRepository
        >
    with $Provider<BrandProfileRepository> {
  BrandProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandProfileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandProfileRepositoryHash();

  @$internal
  @override
  $ProviderElement<BrandProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BrandProfileRepository create(Ref ref) {
    return brandProfileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BrandProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BrandProfileRepository>(value),
    );
  }
}

String _$brandProfileRepositoryHash() =>
    r'c3533be73527afe9dfbc07d642dd09532e1ec94b';

/// The signed-in brand's own `brandProfiles/{uid}` document.

@ProviderFor(ownBrandProfile)
final ownBrandProfileProvider = OwnBrandProfileProvider._();

/// The signed-in brand's own `brandProfiles/{uid}` document.

final class OwnBrandProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<BrandProfile?>,
          BrandProfile?,
          FutureOr<BrandProfile?>
        >
    with $FutureModifier<BrandProfile?>, $FutureProvider<BrandProfile?> {
  /// The signed-in brand's own `brandProfiles/{uid}` document.
  OwnBrandProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ownBrandProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ownBrandProfileHash();

  @$internal
  @override
  $FutureProviderElement<BrandProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BrandProfile?> create(Ref ref) {
    return ownBrandProfile(ref);
  }
}

String _$ownBrandProfileHash() => r'cab3a02a82a0ed866390f03c0fe08033d7d10c2b';

/// Live version of [ownBrandProfileProvider] — the verification-pending
/// screen watches this so it can move on the instant an admin decides,
/// rather than requiring an app relaunch to notice.

@ProviderFor(ownBrandProfileStream)
final ownBrandProfileStreamProvider = OwnBrandProfileStreamProvider._();

/// Live version of [ownBrandProfileProvider] — the verification-pending
/// screen watches this so it can move on the instant an admin decides,
/// rather than requiring an app relaunch to notice.

final class OwnBrandProfileStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<BrandProfile?>,
          BrandProfile?,
          Stream<BrandProfile?>
        >
    with $FutureModifier<BrandProfile?>, $StreamProvider<BrandProfile?> {
  /// Live version of [ownBrandProfileProvider] — the verification-pending
  /// screen watches this so it can move on the instant an admin decides,
  /// rather than requiring an app relaunch to notice.
  OwnBrandProfileStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ownBrandProfileStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ownBrandProfileStreamHash();

  @$internal
  @override
  $StreamProviderElement<BrandProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<BrandProfile?> create(Ref ref) {
    return ownBrandProfileStream(ref);
  }
}

String _$ownBrandProfileStreamHash() =>
    r'7e6b32d7339f5c62a7a6ac11142ac51a24f393d9';

/// A specific brand's `brandProfiles` document by ID — for showing a
/// brand's profile to a creator (e.g. tapping the brand header on a
/// campaign they're viewing), as opposed to [ownBrandProfileProvider]
/// which is always the signed-in brand's own.

@ProviderFor(brandProfileById)
final brandProfileByIdProvider = BrandProfileByIdFamily._();

/// A specific brand's `brandProfiles` document by ID — for showing a
/// brand's profile to a creator (e.g. tapping the brand header on a
/// campaign they're viewing), as opposed to [ownBrandProfileProvider]
/// which is always the signed-in brand's own.

final class BrandProfileByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<BrandProfile?>,
          BrandProfile?,
          FutureOr<BrandProfile?>
        >
    with $FutureModifier<BrandProfile?>, $FutureProvider<BrandProfile?> {
  /// A specific brand's `brandProfiles` document by ID — for showing a
  /// brand's profile to a creator (e.g. tapping the brand header on a
  /// campaign they're viewing), as opposed to [ownBrandProfileProvider]
  /// which is always the signed-in brand's own.
  BrandProfileByIdProvider._({
    required BrandProfileByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'brandProfileByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$brandProfileByIdHash();

  @override
  String toString() {
    return r'brandProfileByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BrandProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BrandProfile?> create(Ref ref) {
    final argument = this.argument as String;
    return brandProfileById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BrandProfileByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$brandProfileByIdHash() => r'cfdc6bcb59803abb1591756661ead2980074386a';

/// A specific brand's `brandProfiles` document by ID — for showing a
/// brand's profile to a creator (e.g. tapping the brand header on a
/// campaign they're viewing), as opposed to [ownBrandProfileProvider]
/// which is always the signed-in brand's own.

final class BrandProfileByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BrandProfile?>, String> {
  BrandProfileByIdFamily._()
    : super(
        retry: null,
        name: r'brandProfileByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A specific brand's `brandProfiles` document by ID — for showing a
  /// brand's profile to a creator (e.g. tapping the brand header on a
  /// campaign they're viewing), as opposed to [ownBrandProfileProvider]
  /// which is always the signed-in brand's own.

  BrandProfileByIdProvider call(String brandId) =>
      BrandProfileByIdProvider._(argument: brandId, from: this);

  @override
  String toString() => r'brandProfileByIdProvider';
}

/// Every brand profile, for the Admin's Brands directory.

@ProviderFor(brandDirectory)
final brandDirectoryProvider = BrandDirectoryProvider._();

/// Every brand profile, for the Admin's Brands directory.

final class BrandDirectoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BrandProfile>>,
          List<BrandProfile>,
          Stream<List<BrandProfile>>
        >
    with
        $FutureModifier<List<BrandProfile>>,
        $StreamProvider<List<BrandProfile>> {
  /// Every brand profile, for the Admin's Brands directory.
  BrandDirectoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandDirectoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandDirectoryHash();

  @$internal
  @override
  $StreamProviderElement<List<BrandProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BrandProfile>> create(Ref ref) {
    return brandDirectory(ref);
  }
}

String _$brandDirectoryHash() => r'13cfbfded9fb898f39a3d11f6d6fe5ddfc68aefa';

/// Drives editing the brand's own profile (bio/industries/website).

@ProviderFor(BrandProfileController)
final brandProfileControllerProvider = BrandProfileControllerProvider._();

/// Drives editing the brand's own profile (bio/industries/website).
final class BrandProfileControllerProvider
    extends $AsyncNotifierProvider<BrandProfileController, void> {
  /// Drives editing the brand's own profile (bio/industries/website).
  BrandProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandProfileControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandProfileControllerHash();

  @$internal
  @override
  BrandProfileController create() => BrandProfileController();
}

String _$brandProfileControllerHash() =>
    r'5c4231a87949df34fa04a3b1ff6c2bfbf8ae1954';

/// Drives editing the brand's own profile (bio/industries/website).

abstract class _$BrandProfileController extends $AsyncNotifier<void> {
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
