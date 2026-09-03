import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'website_footer.dart';
import 'website_header.dart';

/// Shared chrome for every website route — header, scrollable page content,
/// footer, and the mobile nav drawer. Each screen just returns its own
/// content, not its own [Scaffold]. Owns the [ScrollController] so
/// [WebsiteHeader] can react to scroll position (compacting/blurring) even
/// though it sits outside the scroll view itself.
class WebsiteShell extends StatefulWidget {
  const WebsiteShell({super.key, required this.child});

  final Widget child;

  @override
  State<WebsiteShell> createState() => _WebsiteShellState();
}

class _WebsiteShellState extends State<WebsiteShell> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: const WebsiteNavDrawer(),
      body: Column(
        children: [
          WebsiteHeader(scrollController: _scrollController),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(children: [widget.child, const WebsiteFooter()]),
            ),
          ),
        ],
      ),
    );
  }
}
