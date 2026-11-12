// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_intern_campaigns_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(brandInternCampaignsRepository)
final brandInternCampaignsRepositoryProvider =
    BrandInternCampaignsRepositoryProvider._();

final class BrandInternCampaignsRepositoryProvider
    extends
        $FunctionalProvider<
          BrandInternCampaignsRepository,
          BrandInternCampaignsRepository,
          BrandInternCampaignsRepository
        >
    with $Provider<BrandInternCampaignsRepository> {
  BrandInternCampaignsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandInternCampaignsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandInternCampaignsRepositoryHash();

  @$internal
  @override
  $ProviderElement<BrandInternCampaignsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BrandInternCampaignsRepository create(Ref ref) {
    return brandInternCampaignsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BrandInternCampaignsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BrandInternCampaignsRepository>(
        value,
      ),
    );
  }
}

String _$brandInternCampaignsRepositoryHash() =>
    r'781fac002ddc0463979e699829222e970f696dac';

@ProviderFor(myBrandEmailCampaigns)
final myBrandEmailCampaignsProvider = MyBrandEmailCampaignsProvider._();

final class MyBrandEmailCampaignsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BrandEmailCampaign>>,
          List<BrandEmailCampaign>,
          Stream<List<BrandEmailCampaign>>
        >
    with
        $FutureModifier<List<BrandEmailCampaign>>,
        $StreamProvider<List<BrandEmailCampaign>> {
  MyBrandEmailCampaignsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myBrandEmailCampaignsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myBrandEmailCampaignsHash();

  @$internal
  @override
  $StreamProviderElement<List<BrandEmailCampaign>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BrandEmailCampaign>> create(Ref ref) {
    return myBrandEmailCampaigns(ref);
  }
}

String _$myBrandEmailCampaignsHash() =>
    r'1b52e60b75114315f18d619673d8e36e95bd2831';
