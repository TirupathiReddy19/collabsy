import 'package:flutter/material.dart';

/// Reusable background for the Collabsy splash screen.
///
/// This widget recreates the orange gradient background from the
/// Figma design and can be reused anywhere in the app.
class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Main Orange Background
          Container(decoration: const BoxDecoration(color: Color(0xFFF97316))),

          // Top Left Radial Glow
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.55, -0.80),
                  radius: 1.15,
                  colors: [
                    const Color(0xFFFB923C),
                    const Color(0xFFF97316),
                    const Color(0xFFEA580C),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Bottom White Glow
          Positioned(
            left: -80,
            right: -80,
            bottom: -140,
            child: IgnorePointer(
              child: Container(
                height: 320,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white24, Colors.transparent],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Safe Area Content
          SafeArea(child: child),
        ],
      ),
    );
  }
}
