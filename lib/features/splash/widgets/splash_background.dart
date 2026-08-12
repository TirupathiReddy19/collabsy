import 'package:flutter/material.dart';

/// Flat background for the Collabsy splash screen — matches the native
/// Android launch screen's color exactly
/// (android/app/src/main/res/drawable/launch_background.xml,
/// @color/splash_background) so there's no visible color shift when the
/// Dart splash screen takes over from it.
class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF97316),
      body: SafeArea(child: child),
    );
  }
}
