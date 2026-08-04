import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../firebase_options.dart';
import 'intern_app.dart';

/// Mirrors `admin/admin_bootstrap.dart`'s deferred-init pattern — renders a
/// frame immediately instead of blocking on [Firebase.initializeApp].
class InternBootstrap extends StatefulWidget {
  const InternBootstrap({super.key});

  @override
  State<InternBootstrap> createState() => _InternBootstrapState();
}

class _InternBootstrapState extends State<InternBootstrap> {
  late final Future<FirebaseApp> _initFuture = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        return const InternApp();
      },
    );
  }
}
