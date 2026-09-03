import 'package:flutter/material.dart';

/// Fades + slides its child up once it scrolls within ~90% of the
/// viewport, then never re-triggers — the one motion treatment reused
/// across every section/card on the website so the whole site reads as
/// one system rather than a different animation per screen.
///
/// Listens directly to the nearest ancestor [Scrollable]'s position
/// rather than [NotificationListener] — a `NotificationListener` placed on
/// a descendant of the scroll view never actually receives that scroll
/// view's notifications (they only bubble up to true ancestors), so this
/// attaches to [ScrollPosition] itself, which works regardless of where in
/// the tree this widget sits relative to the scrollable.
class ScrollRevealFade extends StatefulWidget {
  const ScrollRevealFade({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<ScrollRevealFade> createState() => _ScrollRevealFadeState();
}

class _ScrollRevealFadeState extends State<ScrollRevealFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  ScrollPosition? _scrollPosition;
  bool _triggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newPosition = Scrollable.maybeOf(context)?.position;
    if (newPosition != _scrollPosition) {
      _scrollPosition?.removeListener(_checkVisibility);
      _scrollPosition = newPosition;
      _scrollPosition?.addListener(_checkVisibility);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (_triggered || !mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) return;
    final position = renderObject.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.sizeOf(context).height;
    if (position.dy < screenHeight * 0.9) {
      _triggered = true;
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
        _controller.value = 1;
        return;
      }
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_checkVisibility);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fade,
      builder: (context, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _fade.value) * 22),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
