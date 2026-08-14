import 'package:flutter/material.dart';

import '../../core/theme/app_breakpoints.dart';

/// Centers [child] within [maxWidth] and adds consistent horizontal/
/// vertical padding — wraps every section of every website page so margins
/// line up regardless of viewport width.
class WebsiteSection extends StatelessWidget {
  const WebsiteSection({
    super.key,
    required this.child,
    this.maxWidth = 1120,
    this.padded = true,
    this.backgroundColor,
  });

  final Widget child;
  final double maxWidth;
  final bool padded;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= AppBreakpoints.tablet ? 48.0 : 20.0;
    final vertical = padded
        ? (width >= AppBreakpoints.tablet ? 72.0 : 48.0)
        : 0.0;

    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: vertical,
          ),
          child: child,
        ),
      ),
    );

    if (backgroundColor == null) return content;
    return ColoredBox(color: backgroundColor!, child: content);
  }
}
