// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intern_leads_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(internLeadsRepository)
final internLeadsRepositoryProvider = InternLeadsRepositoryProvider._();

final class InternLeadsRepositoryProvider
    extends
        $FunctionalProvider<
          InternLeadsRepository,
          InternLeadsRepository,
          InternLeadsRepository
        >
    with $Provider<InternLeadsRepository> {
  InternLeadsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'internLeadsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$internLeadsRepositoryHash();

  @$internal
  @override
  $ProviderElement<InternLeadsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InternLeadsRepository create(Ref ref) {
    return internLeadsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InternLeadsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InternLeadsRepository>(value),
    );
  }
}

String _$internLeadsRepositoryHash() =>
    r'bf971e32aec3e90a37bdd28047d409711e2cefd4';

@ProviderFor(myLeads)
final myLeadsProvider = MyLeadsProvider._();

final class MyLeadsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Lead>>,
          List<Lead>,
          Stream<List<Lead>>
        >
    with $FutureModifier<List<Lead>>, $StreamProvider<List<Lead>> {
  MyLeadsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myLeadsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myLeadsHash();

  @$internal
  @override
  $StreamProviderElement<List<Lead>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Lead>> create(Ref ref) {
    return myLeads(ref);
  }
}

String _$myLeadsHash() => r'3c96f6e1905ecede278b6f35f5f07938dcc70a56';

@ProviderFor(outreachConfig)
final outreachConfigProvider = OutreachConfigProvider._();

final class OutreachConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>?>,
          Map<String, dynamic>?,
          FutureOr<Map<String, dynamic>?>
        >
    with
        $FutureModifier<Map<String, dynamic>?>,
        $FutureProvider<Map<String, dynamic>?> {
  OutreachConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outreachConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outreachConfigHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>?> create(Ref ref) {
    return outreachConfig(ref);
  }
}

String _$outreachConfigHash() => r'9eb984ee0239042bed3bfa57d14099f7be573943';
