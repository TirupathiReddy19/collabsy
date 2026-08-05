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

/// The Collabsy mark: two rounded squares — one solid, one an outline —
/// overlapping at opposing angles. Reads as two parties (creator + brand)
/// meeting in the middle, which is the whole product in one shape, rather
/// than a plain letterform. Vector-drawn so it stays crisp at every size
/// this widget is used at (the 56px auth header through the 96px splash
/// badge) without shipping raster assets.
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
    // Sized + separated so the two squares read as distinctly overlapping
    // shapes rather than merging into a blob — the corner radius stays
    // modest and the center-to-center offset is large relative to the
    // side length specifically to keep each square's own silhouette
    // legible at a glance.
    final squareSide = size.shortestSide * 0.56;
    final cornerRadius = squareSide * 0.18;
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: squareSide,
      height: squareSide,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cornerRadius),
    );
    final offset = squareSide * 0.4;

    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = squareSide * 0.1;

    canvas.save();
    canvas.translate(
      center.dx - offset * math.cos(math.pi / 4),
      center.dy - offset * math.sin(math.pi / 4),
    );
    canvas.rotate(-0.28);
    canvas.drawRRect(rrect, outlinePaint);
    canvas.restore();

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(
      center.dx + offset * math.cos(math.pi / 4),
      center.dy + offset * math.sin(math.pi / 4),
    );
    canvas.rotate(0.28);
    canvas.drawRRect(rrect, fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CollabsyMarkPainter oldPainter) => false;
}
