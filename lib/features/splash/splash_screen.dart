import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/splash_background.dart';
import 'widgets/splash_footer.dart';
import 'widgets/splash_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    // Keep the splash visible for at least 3 seconds
    _timer = Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;

      await _checkAuthentication();
    });
  }

  Future<void> _checkAuthentication() async {
    // -----------------------------------------------------
    // TODO:
    // Replace this with your authentication check.
    //
    // Example (Supabase):
    //
    // final session = Supabase.instance.client.auth.currentSession;
    //
    // if (session != null) {
    //   context.go('/home');
    // } else {
    //   context.go('/login');
    // }
    //
    // -----------------------------------------------------

    final bool isLoggedIn = false;

    if (!mounted) return;

    if (isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SplashBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 24,
        ),
        child: Column(
          children: [
            const Spacer(),

            const SplashLogo(),

            const Spacer(),

            const SplashFooter(),
          ],
        ),
      ),
    );
  }
}