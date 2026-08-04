// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_analytics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allUserSignups)
final allUserSignupsProvider = AllUserSignupsProvider._();

final class AllUserSignupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserSignup>>,
          List<UserSignup>,
          Stream<List<UserSignup>>
        >
    with $FutureModifier<List<UserSignup>>, $StreamProvider<List<UserSignup>> {
  AllUserSignupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allUserSignupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allUserSignupsHash();

  @$internal
  @override
  $StreamProviderElement<List<UserSignup>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<UserSignup>> create(Ref ref) {
    return allUserSignups(ref);
  }
}

String _$allUserSignupsHash() => r'e2f5d859968c425390e4bc36a910490be40afe62';

@ProviderFor(allDailyActivity)
final allDailyActivityProvider = AllDailyActivityProvider._();

final class AllDailyActivityProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DailyActivityEntry>>,
          List<DailyActivityEntry>,
          Stream<List<DailyActivityEntry>>
        >
    with
        $FutureModifier<List<DailyActivityEntry>>,
        $StreamProvider<List<DailyActivityEntry>> {
  AllDailyActivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allDailyActivityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allDailyActivityHash();

  @$internal
  @override
  $StreamProviderElement<List<DailyActivityEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DailyActivityEntry>> create(Ref ref) {
    return allDailyActivity(ref);
  }
}

String _$allDailyActivityHash() => r'7ce5fc942dc8d162392f4a7d059dc1f9873bec3f';
