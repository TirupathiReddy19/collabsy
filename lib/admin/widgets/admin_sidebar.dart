import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/theme_mode_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../models/admin_nav_item.dart';
import '../models/staff_login_event.dart';
import '../providers/admin_auth_providers.dart';
import '../providers/admin_staff_login_event_providers.dart';

const _sidebarBg = Color(0xFF111827);

/// Persistent left navigation — matches the Figma `AdminSidebar` (5 groups,
/// dark background, footer identity card + logout). Filtered down to
/// whichever sections the signed-in account can actually see: unrestricted
/// for the super admin, permission-gated for a staff account (which also
/// never sees Role Management, regardless of its permission map).
class AdminSidebar extends ConsumerWidget {
  const AdminSidebar({super.key, required this.currentPath, this.onNavigate});

  final String currentPath;

  /// Called right after a nav item routes — closes the Drawer on narrow
  /// (responsive) layouts; left `null` on the permanent desktop sidebar.
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSuperAdmin = ref.watch(isAdminProvider);
    final staffAccount = ref.watch(currentStaffAccountProvider).value;
    final activeItemPath = navItemPathFor(currentPath);
    final themeMode = ref.watch(appThemeModeProvider);

    final visibleGroups = isSuperAdmin
        ? adminNavGroups
        : adminNavGroups
              .map(
                (group) => AdminNavGroup(
                  title: group.title,
                  items: group.items
                      .where(
                        (item) =>
                            item.path != '/roles' &&
                            staffAccount?.permissions[item.path] == true,
                      )
                      .toList(),
                ),
              )
              .where((group) => group.items.isNotEmpty)
              .toList();

    return Container(
      width: 260,
      color: _sidebarBg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'C',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Collabsy',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final group in visibleGroups) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
                      child: Text(
                        group.title.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    for (final item in group.items)
                      _SidebarTile(
                        item: item,
                        selected: item.path == activeItemPath,
                        onNavigate: onNavigate,
                      ),
                  ],
                ],
              ),
            ),
            const Divider(color: Color(0xFF1F2937), height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSuperAdmin
                              ? 'Super Admin'
                              : (staffAccount?.roleName ?? 'Staff'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          isSuperAdmin
                              ? adminEmail
                              : (staffAccount?.email ?? ''),
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      color: const Color(0xFF9CA3AF),
                      size: 18,
                    ),
                    tooltip: themeMode == ThemeMode.dark
                        ? 'Switch to light mode'
                        : 'Switch to dark mode',
                    onPressed: () =>
                        ref.read(appThemeModeProvider.notifier).toggle(),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Color(0xFF9CA3AF),
                      size: 18,
                    ),
                    tooltip: 'Sign out',
                    onPressed: () async {
                      if (staffAccount != null) {
                        await ref
                            .read(adminStaffLoginEventRepositoryProvider)
                            .logEvent(
                              uid: staffAccount.uid,
                              email: staffAccount.email,
                              roleName: staffAccount.roleName,
                              type: StaffLoginEventType.logout,
                            );
                      }
                      await ref.read(authRepositoryProvider).signOut();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _sidebarTileTransition = Duration(milliseconds: 220);

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.selected,
    this.onNavigate,
  });

  final AdminNavItem item;
  final bool selected;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        // Transparent, not `null` — with the default `MaterialType.canvas`
        // a null color falls back to `Theme.of(context).canvasColor`,
        // which is the mobile app's light peach background (shared via
        // `AppTheme.lightTheme`). That painted a pale box behind every row,
        // making the white label unreadable against it. The actual
        // selected/unselected background lives on the AnimatedContainer
        // below instead, so it can fade in/out rather than snap.
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            context.go(item.path);
            onNavigate?.call();
          },
          child: AnimatedContainer(
            duration: _sidebarTileTransition,
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                    begin: const Color(0xFFD1D5DB),
                    end: selected ? AppColors.primary : const Color(0xFFD1D5DB),
                  ),
                  duration: _sidebarTileTransition,
                  builder: (context, color, child) =>
                      Icon(item.icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: _sidebarTileTransition,
                    style: TextStyle(
                      color: selected ? AppColors.primary : Colors.white,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    child: Text(item.label),
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
