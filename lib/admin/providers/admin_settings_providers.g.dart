// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminSettingsRepository)
final adminSettingsRepositoryProvider = AdminSettingsRepositoryProvider._();

final class AdminSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AdminSettingsRepository,
          AdminSettingsRepository,
          AdminSettingsRepository
        >
    with $Provider<AdminSettingsRepository> {
  AdminSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminSettingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminSettingsRepository create(Ref ref) {
    return adminSettingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminSettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminSettingsRepository>(value),
    );
  }
}

String _$adminSettingsRepositoryHash() =>
    r'36005f6270106d588c9d058e10b0ae1ac3b6acf8';

@ProviderFor(outreachLinksConfig)
final outreachLinksConfigProvider = OutreachLinksConfigProvider._();

final class OutreachLinksConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>?>,
          Map<String, dynamic>?,
          FutureOr<Map<String, dynamic>?>
        >
    with
        $FutureModifier<Map<String, dynamic>?>,
        $FutureProvider<Map<String, dynamic>?> {
  OutreachLinksConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outreachLinksConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outreachLinksConfigHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>?> create(Ref ref) {
    return outreachLinksConfig(ref);
  }
}

String _$outreachLinksConfigHash() =>
    r'939d74d8d9fdf929526e7753992bd9954c4773b4';

@ProviderFor(brandOutreachLinksConfig)
final brandOutreachLinksConfigProvider = BrandOutreachLinksConfigProvider._();

final class BrandOutreachLinksConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>?>,
          Map<String, dynamic>?,
          FutureOr<Map<String, dynamic>?>
        >
    with
        $FutureModifier<Map<String, dynamic>?>,
        $FutureProvider<Map<String, dynamic>?> {
  BrandOutreachLinksConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandOutreachLinksConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandOutreachLinksConfigHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>?> create(Ref ref) {
    return brandOutreachLinksConfig(ref);
  }
}

String _$brandOutreachLinksConfigHash() =>
    r'8f729a1aedf590f7d30f61c324e7e4be6d5ac265';
