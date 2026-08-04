import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/local_storage_service.dart';
import 'intern/intern_bootstrap.dart';

/// Separate entry point for the intern outreach tool — built and deployed
/// via `flutter build web -t lib/main_intern.dart`, completely independent
/// of `lib/main.dart` (the Creator/Brand mobile app) and `lib/main_admin.dart`
/// (the Admin portal). Nothing under `lib/intern/` is ever imported from
/// either of those, so neither build bloats with outreach-tool code.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const InternBootstrap(),
    ),
  );
}
