import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'brand_intern/brand_intern_bootstrap.dart';
import 'core/services/local_storage_service.dart';

/// Separate entry point for the brand outreach tool — built and deployed
/// via `flutter build web -t lib/main_brand_intern.dart`, completely
/// independent of `lib/main.dart` (the Creator/Brand mobile app),
/// `lib/main_admin.dart` (the Admin portal), and `lib/main_intern.dart`
/// (the creator outreach tool). Nothing under `lib/brand_intern/` is ever
/// imported from any of those, so none of those builds bloat with brand
/// outreach code.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const BrandInternBootstrap(),
    ),
  );
}
