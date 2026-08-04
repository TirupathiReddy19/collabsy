import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/local_storage_service.dart';

part 'theme_mode_providers.g.dart';

const _themeModeKey = 'admin_theme_mode';

/// Light/dark toggle for the admin portal and intern outreach tool (the
/// mobile app doesn't use this — its `MaterialApp` sets `theme:` only, no
/// `darkTheme:`/`themeMode:`, so this provider has no effect there even
/// though it lives in `core/` alongside the shared [sharedPreferencesProvider]
/// it persists through). Lives outside `lib/admin/` and `lib/intern/` since
/// both need it and those directories are never cross-imported.
@Riverpod(keepAlive: true)
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() {
    final stored = ref
        .watch(sharedPreferencesProvider)
        .getString(_themeModeKey);
    return stored == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_themeModeKey, next == ThemeMode.dark ? 'dark' : 'light');
  }
}
