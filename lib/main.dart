import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_bootstrap.dart';
import 'core/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android 15+ (targetSdk 35+, which Flutter's default now is) forces
  // edge-to-edge display regardless of what the app does — opting in
  // explicitly here (rather than leaving Flutter to assume the old,
  // non-edge-to-edge default) is what makes MediaQuery's insets and
  // SafeArea compute correctly against the real system bar sizes on
  // every Android version, not just the ones that force it.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const AppBootstrap(),
    ),
  );
}
