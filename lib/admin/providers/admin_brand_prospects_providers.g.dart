// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_brand_prospects_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminBrandProspectsRepository)
final adminBrandProspectsRepositoryProvider =
    AdminBrandProspectsRepositoryProvider._();

final class AdminBrandProspectsRepositoryProvider
    extends
        $FunctionalProvider<
          AdminBrandProspectsRepository,
          AdminBrandProspectsRepository,
          AdminBrandProspectsRepository
        >
    with $Provider<AdminBrandProspectsRepository> {
  AdminBrandProspectsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminBrandProspectsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminBrandProspectsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminBrandProspectsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminBrandProspectsRepository create(Ref ref) {
    return adminBrandProspectsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminBrandProspectsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminBrandProspectsRepository>(
        value,
      ),
    );
  }
}

String _$adminBrandProspectsRepositoryHash() =>
    r'9624fe48691a1532d439f6cb90c1f3e16b4af1a8';

@ProviderFor(brandProspectCategoryBreakdown)
final brandProspectCategoryBreakdownProvider =
    BrandProspectCategoryBreakdownProvider._();

final class BrandProspectCategoryBreakdownProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BrandProspectCategoryCounts>>,
          List<BrandProspectCategoryCounts>,
          FutureOr<List<BrandProspectCategoryCounts>>
        >
    with
        $FutureModifier<List<BrandProspectCategoryCounts>>,
        $FutureProvider<List<BrandProspectCategoryCounts>> {
  BrandProspectCategoryBreakdownProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandProspectCategoryBreakdownProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandProspectCategoryBreakdownHash();

  @$internal
  @override
  $FutureProviderElement<List<BrandProspectCategoryCounts>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BrandProspectCategoryCounts>> create(Ref ref) {
    return brandProspectCategoryBreakdown(ref);
  }
}

String _$brandProspectCategoryBreakdownHash() =>
    r'd101c0cf5c677741fda2b6e27c249021f0c6aa15';

@ProviderFor(brandProspectTotalImported)
final brandProspectTotalImportedProvider =
    BrandProspectTotalImportedProvider._();

final class BrandProspectTotalImportedProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  BrandProspectTotalImportedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandProspectTotalImportedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandProspectTotalImportedHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return brandProspectTotalImported(ref);
  }
}

String _$brandProspectTotalImportedHash() =>
    r'ac636a29e0ce94b1920090981e52ddf68a55154b';
