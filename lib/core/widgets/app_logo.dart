import 'dart:math' as math;
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
    final double markSize = size * 0.5;

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
                child: SizedBox(
                  width: markSize,
                  height: markSize,
                  child: const _CollabsyMark(),
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
            "India's Premier\nInfluencer Marketing Platform",
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

/// The Collabsy mark: an open white ring (a "C") with a smaller two-tone
/// accent ring nested in its gap — the same geometry as the app icon
/// (assets/icon/collabsy_icon_master.png and the Android adaptive icon's
/// ic_launcher_foreground.xml), so the in-app logo, splash screen, and
/// home-screen icon all read as the same mark. Vector-drawn so it stays
/// crisp at every size this widget is used at (the 56px auth header
/// through the 96px splash badge) without shipping raster assets.
class _CollabsyMark extends StatelessWidget {
  const _CollabsyMark();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CollabsyMarkPainter());
  }
}

class _CollabsyMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Source geometry lives in a 100x100 logical box (the icon SVG's own
    // local coordinate space) — scaled to occupy ~62% of the given size,
    // the same proportion as the app icon's adaptive-icon safe zone, and
    // centered.
    final scale = size.shortestSide * 0.62 / 100;
    Offset toCanvas(double lx, double ly) =>
        center + Offset((lx - 50) * scale, (ly - 50) * scale);
    final strokeWidth = 14 * scale;

    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: toCanvas(53.345, 50), radius: 32 * scale),
      -54.3665 * math.pi / 180,
      -251.267 * math.pi / 180,
      false,
      outerPaint,
    );

    final innerPaint = Paint()
      ..color = const Color(0xFFB85C18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: toCanvas(64.247, 50), radius: 18 * scale),
      -117.25 * math.pi / 180,
      234.5 * math.pi / 180,
      false,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CollabsyMarkPainter oldPainter) => false;
}
