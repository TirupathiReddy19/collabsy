import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/local_storage_service.dart';
import 'website/website_bootstrap.dart';

/// Separate entry point for the public marketing website — built and
/// deployed via `flutter build web -t lib/main_website.dart`, completely
/// independent of `lib/main.dart` (mobile app), `lib/main_admin.dart`
/// (Admin portal), and the intern tools. Nothing under `lib/website/` is
/// ever imported from any of those.
///
/// Unlike the other web targets, this one is public and needs real,
/// shareable URLs (`/creators`, `/brands`, ...) rather than `/#/...` hash
/// routes, so it opts into path-based URL routing.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const WebsiteBootstrap(),
    ),
  );
}
