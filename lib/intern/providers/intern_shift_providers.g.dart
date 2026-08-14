// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intern_shift_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(internShiftRepository)
final internShiftRepositoryProvider = InternShiftRepositoryProvider._();

final class InternShiftRepositoryProvider
    extends
        $FunctionalProvider<
          InternShiftRepository,
          InternShiftRepository,
          InternShiftRepository
        >
    with $Provider<InternShiftRepository> {
  InternShiftRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'internShiftRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$internShiftRepositoryHash();

  @$internal
  @override
  $ProviderElement<InternShiftRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InternShiftRepository create(Ref ref) {
    return internShiftRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InternShiftRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InternShiftRepository>(value),
    );
  }
}

String _$internShiftRepositoryHash() =>
    r'cc313d992c41ce15c9d3b5b479f1417ac8723ff3';

@ProviderFor(myShiftActiveSecondsToday)
final myShiftActiveSecondsTodayProvider = MyShiftActiveSecondsTodayProvider._();

final class MyShiftActiveSecondsTodayProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  MyShiftActiveSecondsTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myShiftActiveSecondsTodayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myShiftActiveSecondsTodayHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return myShiftActiveSecondsToday(ref);
  }
}

String _$myShiftActiveSecondsTodayHash() =>
    r'7bc17569cbd890efd110cd251df7feb92897fe32';
