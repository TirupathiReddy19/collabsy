import 'package:flutter/material.dart';

/// Wraps a card so it lifts slightly and gains a soft shadow under the
/// mouse — the one hover treatment reused for every card on the website
/// (audience cards, principle cards, service cards) so hovering anything
/// reads as the same interactive surface. No-ops on touch devices, since
/// there's no hover there to begin with.
class HoverLift extends StatefulWidget {
  const HoverLift({super.key, required this.child, this.borderRadius = 24});

  final Widget child;
  final double borderRadius;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ]
              : const [],
        ),
        child: widget.child,
      ),
    );
  }
}
