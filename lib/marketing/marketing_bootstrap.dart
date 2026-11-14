import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../core/config/emulator_config.dart';
import '../core/theme/app_theme.dart';
import '../firebase_options.dart';
import 'marketing_app.dart';

/// Mirrors `brand_intern/brand_intern_bootstrap.dart`'s deferred-init
/// pattern — renders a frame immediately instead of blocking on
/// [Firebase.initializeApp].
class MarketingBootstrap extends StatefulWidget {
  const MarketingBootstrap({super.key});

  @override
  State<MarketingBootstrap> createState() => _MarketingBootstrapState();
}

class _MarketingBootstrapState extends State<MarketingBootstrap> {
  late final Future<FirebaseApp> _initFuture = Firebase.initializeApp(
    options: emulatorAwareOptions(DefaultFirebaseOptions.currentPlatform),
  ).then((app) {
    connectToFirebaseEmulatorsIfEnabled();
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
                    'and reload the page.\n${snapshot.error}',
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
        return const MarketingApp();
      },
    );
  }
}
