import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'website_footer.dart';
import 'website_header.dart';

/// Shared chrome for every website route — header, scrollable page content,
/// footer, and the mobile nav drawer. Each screen just returns its own
/// content, not its own [Scaffold].
class WebsiteShell extends StatelessWidget {
  const WebsiteShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: const WebsiteNavDrawer(),
      body: Column(
        children: [
          const WebsiteHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [child, const WebsiteFooter()]),
            ),
          ),
        ],
      ),
    );
  }
}
