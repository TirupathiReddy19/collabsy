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
/// hamburger opening [WebsiteNavDrawer] below it.
class WebsiteHeader extends StatelessWidget {
  const WebsiteHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;
    final location = GoRouterState.of(context).matchedLocation;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 48 : 20,
          vertical: 16,
        ),
        child: Row(
          children: [
            InkWell(onTap: () => context.go('/'), child: const _BrandMark()),
            const Spacer(),
            if (isWide) ...[
              for (final (path, label) in _navItems)
                _NavLink(path: path, label: label, active: location == path),
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
