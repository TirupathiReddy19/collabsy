import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin/admin_bootstrap.dart';
import 'core/services/local_storage_service.dart';

/// Separate entry point for the Admin web portal — built and deployed via
/// `flutter build web -t lib/main_admin.dart`, completely independent of
/// `lib/main.dart` (the Creator/Brand mobile app). Nothing under `lib/admin/`
/// is ever imported from the mobile entry point, so the mobile build never
/// bloats with admin-only code.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const AdminBootstrap(),
    ),
  );
}
