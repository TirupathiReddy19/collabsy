// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_intern_prospects_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(brandInternProspectsRepository)
final brandInternProspectsRepositoryProvider =
    BrandInternProspectsRepositoryProvider._();

final class BrandInternProspectsRepositoryProvider
    extends
        $FunctionalProvider<
          BrandInternProspectsRepository,
          BrandInternProspectsRepository,
          BrandInternProspectsRepository
        >
    with $Provider<BrandInternProspectsRepository> {
  BrandInternProspectsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandInternProspectsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandInternProspectsRepositoryHash();

  @$internal
  @override
  $ProviderElement<BrandInternProspectsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BrandInternProspectsRepository create(Ref ref) {
    return brandInternProspectsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BrandInternProspectsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BrandInternProspectsRepository>(
        value,
      ),
    );
  }
}

String _$brandInternProspectsRepositoryHash() =>
    r'b26362cef6380aeaa85c578d83e8c224c7692197';

@ProviderFor(myBrandProspects)
final myBrandProspectsProvider = MyBrandProspectsProvider._();

final class MyBrandProspectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BrandProspect>>,
          List<BrandProspect>,
          Stream<List<BrandProspect>>
        >
    with
        $FutureModifier<List<BrandProspect>>,
        $StreamProvider<List<BrandProspect>> {
  MyBrandProspectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myBrandProspectsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myBrandProspectsHash();

  @$internal
  @override
  $StreamProviderElement<List<BrandProspect>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BrandProspect>> create(Ref ref) {
    return myBrandProspects(ref);
  }
}

String _$myBrandProspectsHash() => r'd749036965503ee60758a894bb11f601b3fb890d';
