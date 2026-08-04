import 'package:flutter/material.dart';

/// A small square badge recreating LinkedIn's recognizable brand blue with
/// its lowercase "in" wordmark, used anywhere the app references a
/// LinkedIn link — this app doesn't ship LinkedIn's actual logo asset,
/// just the brand color/wordmark people associate with it.
class LinkedInIcon extends StatelessWidget {
  const LinkedInIcon({
    super.key,
    this.size = 32,
    this.fontSize,
    this.monochrome = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  final double size;
  final double? fontSize;

  /// When true, renders just the "in" glyph with no colored background —
  /// for placing on top of an already-colored surface (e.g. the translucent
  /// circular quick-action buttons on a brand-colored header), where the
  /// solid LinkedIn-blue square badge clashes.
  final bool monochrome;

  /// Overrides the default LinkedIn-blue badge background — e.g. to match
  /// a list row's own icon-container color (like every other row in that
  /// list) instead of standing out as a solid blue square.
  final Color? backgroundColor;

  /// Overrides the glyph color — defaults to white on a colored background,
  /// or LinkedIn blue when [monochrome] (no background of its own to
  /// contrast against).
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final glyph = Text(
      'in',
      style: TextStyle(
        color: foregroundColor ?? Colors.white,
        fontSize: fontSize ?? size * 0.55,
        fontWeight: FontWeight.w800,
        height: 1,
      ),
    );
    if (monochrome) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(child: glyph),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF0A66C2),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: glyph,
    );
  }
}
