// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Light/dark toggle for the admin portal and intern outreach tool (the
/// mobile app doesn't use this — its `MaterialApp` sets `theme:` only, no
/// `darkTheme:`/`themeMode:`, so this provider has no effect there even
/// though it lives in `core/` alongside the shared [sharedPreferencesProvider]
/// it persists through). Lives outside `lib/admin/` and `lib/intern/` since
/// both need it and those directories are never cross-imported.

@ProviderFor(AppThemeMode)
final appThemeModeProvider = AppThemeModeProvider._();

/// Light/dark toggle for the admin portal and intern outreach tool (the
/// mobile app doesn't use this — its `MaterialApp` sets `theme:` only, no
/// `darkTheme:`/`themeMode:`, so this provider has no effect there even
/// though it lives in `core/` alongside the shared [sharedPreferencesProvider]
/// it persists through). Lives outside `lib/admin/` and `lib/intern/` since
/// both need it and those directories are never cross-imported.
final class AppThemeModeProvider
    extends $NotifierProvider<AppThemeMode, ThemeMode> {
  /// Light/dark toggle for the admin portal and intern outreach tool (the
  /// mobile app doesn't use this — its `MaterialApp` sets `theme:` only, no
  /// `darkTheme:`/`themeMode:`, so this provider has no effect there even
  /// though it lives in `core/` alongside the shared [sharedPreferencesProvider]
  /// it persists through). Lives outside `lib/admin/` and `lib/intern/` since
  /// both need it and those directories are never cross-imported.
  AppThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeModeHash();

  @$internal
  @override
  AppThemeMode create() => AppThemeMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$appThemeModeHash() => r'6a2ba43c5fc988cc9dbcb064c2b44e79cada6fda';

/// Light/dark toggle for the admin portal and intern outreach tool (the
/// mobile app doesn't use this — its `MaterialApp` sets `theme:` only, no
/// `darkTheme:`/`themeMode:`, so this provider has no effect there even
/// though it lives in `core/` alongside the shared [sharedPreferencesProvider]
/// it persists through). Lives outside `lib/admin/` and `lib/intern/` since
/// both need it and those directories are never cross-imported.

abstract class _$AppThemeMode extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
