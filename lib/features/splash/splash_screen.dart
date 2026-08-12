import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import 'widgets/splash_background.dart';
import 'widgets/splash_logo.dart';

/// Shows for a minimum of 3 seconds, then always moves to the same fixed
/// next step (onboarding). The router's central `redirect()` guard is what
/// actually decides where the user ends up — this screen never checks auth
/// state itself.
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
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) context.go(AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SplashBackground(child: Center(child: SplashLogo()));
  }
}
