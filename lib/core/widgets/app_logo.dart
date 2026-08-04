import 'dart:ui';

import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 96,
    this.showText = true,
    this.showTagline = false,
  });

  /// Size of the logo card.
  final double size;

  /// Whether to show "Collabsy".
  final bool showText;

  /// Whether to show the AI tagline.
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final double borderRadius = size * 0.25;
    final double logoFontSize = size * 0.44;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.30),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  "C",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: logoFontSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
          ),
        ),

        if (showText) ...[
          const SizedBox(height: 20),
          const Text(
            "Collabsy",
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
        ],

        if (showTagline) ...[
          const SizedBox(height: 14),
          Text(
            "India's Premier AI-Powered\nInfluencer Marketing Platform",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
