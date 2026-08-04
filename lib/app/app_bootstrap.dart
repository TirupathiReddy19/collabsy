import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../firebase_options.dart';
import 'app.dart';

/// Renders the first frame immediately instead of blocking on
/// [Firebase.initializeApp] before `runApp()` — if that call stalls (slow
/// network, cold-booted emulator, etc.) the screen would otherwise stay
/// solid black forever with no widget tree ever attached and no visible
/// error.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<FirebaseApp> _initFuture =
      Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).then((app) {
        // Crashlytics needs a live Firebase app before these handlers do
        // anything useful, so they're wired here rather than in main() — kept
        // off in debug builds so local development errors don't get reported.
        if (!kDebugMode) {
          FlutterError.onError =
              FirebaseCrashlytics.instance.recordFlutterFatalError;
          PlatformDispatcher.instance.onError = (error, stack) {
            FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
            return true;
          };
        }
        return app;
      });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    "Couldn't connect. Check your internet connection "
                    'and restart the app.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return const CollabsyApp();
      },
    );
  }
}
