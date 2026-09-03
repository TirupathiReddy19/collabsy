import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../firebase_options.dart';
import 'website_app.dart';

/// Mirrors `brand_intern/brand_intern_bootstrap.dart`'s deferred-init
/// pattern — renders a frame immediately instead of blocking on
/// [Firebase.initializeApp].
class WebsiteBootstrap extends StatefulWidget {
  const WebsiteBootstrap({super.key});

  @override
  State<WebsiteBootstrap> createState() => _WebsiteBootstrapState();
}

class _WebsiteBootstrapState extends State<WebsiteBootstrap> {
  late final Future<FirebaseApp> _initFuture = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Deliberately `builder:`, not `home:` — a `home` (or `routes` /
          // `onGenerateRoute`) makes MaterialApp stand up its own Navigator,
          // which on web immediately writes browser history for its own
          // implicit "/" route. That clobbers the real address bar URL
          // (e.g. /contact) before the real WebsiteApp/GoRouter below ever
          // mounts to read it, silently redirecting every deep link to
          // Home. `builder`-only skips the Navigator entirely.
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            builder: (context, child) => Scaffold(
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
          // See the comment above — `builder:`, not `home:`, for the same
          // reason.
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            builder: (context, child) => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return const WebsiteApp();
      },
    );
  }
}
