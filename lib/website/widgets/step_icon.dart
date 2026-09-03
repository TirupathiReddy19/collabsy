import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';

/// The icon treatment shared by every icon-led list across the website
/// (How It Works, Why Collabsy, services, steps) — a soft gradient tile
/// rather than a flat tinted circle, so these read as a designed detail
/// instead of a placeholder icon. [color] defaults to the brand orange but
/// can be swapped (e.g. per-audience accent colors).
class StepIcon extends StatelessWidget {
  const StepIcon({super.key, required this.icon, this.color = AppColors.primary});

  final IconData icon;
  final Color color;
  static const _size = 52.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.16), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Icon(icon, color: color, size: _size * 0.42),
    );
  }
}
