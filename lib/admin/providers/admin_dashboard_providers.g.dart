// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Real Firestore-backed counts for the dashboard's top stat row — no
/// wallet/GMV/revenue numbers, since no financial feature exists yet.

@ProviderFor(totalCreatorsCount)
final totalCreatorsCountProvider = TotalCreatorsCountProvider._();

/// Real Firestore-backed counts for the dashboard's top stat row — no
/// wallet/GMV/revenue numbers, since no financial feature exists yet.

final class TotalCreatorsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Real Firestore-backed counts for the dashboard's top stat row — no
  /// wallet/GMV/revenue numbers, since no financial feature exists yet.
  TotalCreatorsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalCreatorsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalCreatorsCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return totalCreatorsCount(ref);
  }
}

String _$totalCreatorsCountHash() =>
    r'4a1c56f1028b7f2e49175416a3af82a47106af9f';

@ProviderFor(totalBrandsCount)
final totalBrandsCountProvider = TotalBrandsCountProvider._();

final class TotalBrandsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  TotalBrandsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalBrandsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalBrandsCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return totalBrandsCount(ref);
  }
}

String _$totalBrandsCountHash() => r'ee192b98997145958f39f5307bef8e12f33a0505';

@ProviderFor(activeCampaignsCount)
final activeCampaignsCountProvider = ActiveCampaignsCountProvider._();

final class ActiveCampaignsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  ActiveCampaignsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeCampaignsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeCampaignsCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return activeCampaignsCount(ref);
  }
}

String _$activeCampaignsCountHash() =>
    r'3d6980b4c9296982c217f633d6e160032463bcd0';

@ProviderFor(totalApplicationsCount)
final totalApplicationsCountProvider = TotalApplicationsCountProvider._();

final class TotalApplicationsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  TotalApplicationsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalApplicationsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalApplicationsCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return totalApplicationsCount(ref);
  }
}

String _$totalApplicationsCountHash() =>
    r'bd627accfcfe09ddd18dbd067d789bdea5a6eb55';
