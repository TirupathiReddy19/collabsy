// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_intern_leads_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(brandInternLeadsRepository)
final brandInternLeadsRepositoryProvider =
    BrandInternLeadsRepositoryProvider._();

final class BrandInternLeadsRepositoryProvider
    extends
        $FunctionalProvider<
          BrandInternLeadsRepository,
          BrandInternLeadsRepository,
          BrandInternLeadsRepository
        >
    with $Provider<BrandInternLeadsRepository> {
  BrandInternLeadsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandInternLeadsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandInternLeadsRepositoryHash();

  @$internal
  @override
  $ProviderElement<BrandInternLeadsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BrandInternLeadsRepository create(Ref ref) {
    return brandInternLeadsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BrandInternLeadsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BrandInternLeadsRepository>(value),
    );
  }
}

String _$brandInternLeadsRepositoryHash() =>
    r'05c4472fc45d4a7a8cea82cf4e125dfa7c64f03f';

@ProviderFor(myBrandLeads)
final myBrandLeadsProvider = MyBrandLeadsProvider._();

final class MyBrandLeadsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BrandLead>>,
          List<BrandLead>,
          Stream<List<BrandLead>>
        >
    with $FutureModifier<List<BrandLead>>, $StreamProvider<List<BrandLead>> {
  MyBrandLeadsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myBrandLeadsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myBrandLeadsHash();

  @$internal
  @override
  $StreamProviderElement<List<BrandLead>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BrandLead>> create(Ref ref) {
    return myBrandLeads(ref);
  }
}

String _$myBrandLeadsHash() => r'59d8764e06ab1fb9b108c4a42a30408827884414';

@ProviderFor(brandOutreachConfig)
final brandOutreachConfigProvider = BrandOutreachConfigProvider._();

final class BrandOutreachConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>?>,
          Map<String, dynamic>?,
          FutureOr<Map<String, dynamic>?>
        >
    with
        $FutureModifier<Map<String, dynamic>?>,
        $FutureProvider<Map<String, dynamic>?> {
  BrandOutreachConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandOutreachConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandOutreachConfigHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>?> create(Ref ref) {
    return brandOutreachConfig(ref);
  }
}

String _$brandOutreachConfigHash() =>
    r'b21564fa92657ab69c7e061cb1802f62c0d58389';
