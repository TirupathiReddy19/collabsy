import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_logo.dart';
import 'waitlist_cta_button.dart';

const _navItems = [
  ('/', 'Home'),
  ('/creators', 'Creators'),
  ('/brands', 'Brands'),
  ('/about', 'About'),
  ('/contact', 'Contact'),
];

/// Site-wide header — a full nav row at/above [AppBreakpoints.tablet], a
/// hamburger opening [WebsiteNavDrawer] below it. Compacts and gains a
/// blurred, shadowed background once the page scrolls past a few pixels,
/// via [scrollController] (owned by [WebsiteShell], which sits above this
/// in the tree — the scroll view itself is a sibling of this header, not
/// an ancestor, so listening to `Scrollable.of(context)` from here
/// wouldn't find it).
class WebsiteHeader extends StatefulWidget {
  const WebsiteHeader({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<WebsiteHeader> createState() => _WebsiteHeaderState();
}

class _WebsiteHeaderState extends State<WebsiteHeader> {
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled = widget.scrollController.hasClients &&
        widget.scrollController.offset > 8;
    if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;
    final location = GoRouterState.of(context).matchedLocation;

    return ClipRect(
      child: BackdropFilter(
        filter: _scrolled
            ? ImageFilter.blur(sigmaX: 16, sigmaY: 16)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: _scrolled ? 0.86 : 1),
            border: Border(
              bottom: BorderSide(
                color: _scrolled ? AppColors.border : Colors.transparent,
              ),
            ),
            boxShadow: _scrolled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 48 : 20,
              vertical: _scrolled ? 12 : 16,
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => context.go('/'),
                  child: const _BrandMark(),
                ),
                const Spacer(),
                if (isWide) ...[
                  for (final (path, label) in _navItems)
                    _NavLink(
                      path: path,
                      label: label,
                      active: location == path,
                    ),
                  const SizedBox(width: 12),
                  const WaitlistCtaButton.compact(),
                ] else
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      icon: const Icon(Icons.menu_rounded),
                      tooltip: 'Menu',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: SizedBox(width: 22, height: 22, child: CollabsyMark()),
          ),
        ),
        const SizedBox(width: 10),
        Text('Collabsy', style: AppTextStyles.heading2),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.path,
    required this.label,
    required this.active,
  });

  final String path;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () => context.go(path),
        child: Text(
          label,
          style: AppTextStyles.titleSmall.copyWith(
            color: active ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Mobile nav — opened from the header's hamburger via `endDrawer`.
class WebsiteNavDrawer extends StatelessWidget {
  const WebsiteNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _BrandMark(),
            ),
            const SizedBox(height: 16),
            for (final (path, label) in _navItems)
              ListTile(
                title: Text(label, style: AppTextStyles.titleMedium),
                selected: location == path,
                selectedColor: AppColors.primary,
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(path);
                },
              ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: WaitlistCtaButton(),
            ),
          ],
        ),
      ),
    );
  }
}
