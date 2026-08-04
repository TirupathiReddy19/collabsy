import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/admin_sidebar.dart';
import '../theme/admin_colors.dart';

/// Persistent chrome wrapping every authenticated admin screen — sidebar on
/// the left, routed content on the right. Mirrors the Figma prototype's
/// `AdminApp` root layout (minus the top exit-strip, which doesn't apply
/// here since there's no "other portal" to exit back to).
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  static const _narrowBreakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final isNarrow = MediaQuery.sizeOf(context).width < _narrowBreakpoint;

    if (!isNarrow) {
      return Scaffold(
        backgroundColor: AdminColors.background(context),
        body: Row(
          children: [
            AdminSidebar(currentPath: currentPath),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AdminColors.background(context),
      appBar: AppBar(title: const Text('Collabsy Admin')),
      drawer: Drawer(
        width: 260,
        child: AdminSidebar(
          currentPath: currentPath,
          onNavigate: () => Navigator.of(context).pop(),
        ),
      ),
      body: child,
    );
  }
}
