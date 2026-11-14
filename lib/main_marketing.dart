import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/local_storage_service.dart';
import 'marketing/marketing_bootstrap.dart';

/// Separate entry point for the marketing tracker — built and deployed via
/// `flutter build web -t lib/main_marketing.dart` to the `collabsy-marketing`
/// hosting target, completely independent of every other web build.
/// Nothing under `lib/marketing/` is ever imported from any of those, and
/// nothing under `lib/admin/` or `lib/brand_intern/` is ever imported here
/// (this mirrors staffAccounts queries that already exist there — see
/// `marketing_tasks_providers.dart` — rather than cross-importing).
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MarketingBootstrap(),
    ),
  );
}
