import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import 'widgets/splash_background.dart';
import 'widgets/splash_footer.dart';
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
    return SplashBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          children: [
            // Weighted 3:2 rather than two equal Spacers — an even split
            // left a large empty gap between the tagline and the loading
            // indicator on taller screens. This keeps the logo roughly
            // centered in the upper portion and the footer anchored near
            // the bottom, scaling proportionally on any screen size.
            const Expanded(flex: 3, child: Center(child: SplashLogo())),
            const Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SplashFooter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
