import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Soft, out-of-focus color blobs behind the hero copy — the one bit of
/// visual interest the hero needs so it doesn't read as bare text on an
/// empty background. Deliberately not literal shapes/icons: three
/// oversized, heavily-blurred circles in the brand's own accent colors
/// (orange, the Creator violet, the Brand blue — the same duality the
/// site's copy is about), positioned toward the edges so the text itself
/// always sits over a clear, low-contrast area.
class HeroBackdrop extends StatelessWidget {
  const HeroBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: ClipRect(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: Stack(
              children: [
                Positioned(
                  top: -80,
                  left: -60,
                  child: _Blob(color: AppColors.primary.withValues(alpha: 0.22)),
                ),
                Positioned(
                  top: 40,
                  right: -100,
                  child: _Blob(color: AppColors.brand.withValues(alpha: 0.16)),
                ),
                Positioned(
                  bottom: -120,
                  left: 80,
                  child: _Blob(color: AppColors.creator.withValues(alpha: 0.14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 340,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
