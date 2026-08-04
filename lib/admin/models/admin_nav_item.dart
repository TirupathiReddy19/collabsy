import 'package:flutter/material.dart';

/// One entry in the admin sidebar — mirrors the Figma prototype's
/// `AdminSidebar` nav model (id/label/icon/badge), grouped into sections.
class AdminNavItem {
  const AdminNavItem({
    required this.path,
    required this.label,
    required this.icon,
  });

  final String path;
  final String label;
  final IconData icon;
}

class AdminNavGroup {
  const AdminNavGroup({required this.title, required this.items});

  final String title;
  final List<AdminNavItem> items;
}

/// Matches the Figma `AdminSidebar` exactly: 5 groups, 17 items, plus
/// Reports (added later, not in the original Figma prototype). Screens not
/// yet built (see `AdminComingSoonScreen`) still get a route so the whole
/// sidebar is navigable today.
const adminNavGroups = [
  AdminNavGroup(
    title: 'Overview',
    items: [
      AdminNavItem(
        path: '/dashboard',
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
      ),
      AdminNavItem(
        path: '/analytics',
        label: 'Platform Analytics',
        icon: Icons.bar_chart_outlined,
      ),
      AdminNavItem(
        path: '/reports',
        label: 'Reports',
        icon: Icons.summarize_outlined,
      ),
      AdminNavItem(
        path: '/revenue',
        label: 'Revenue',
        icon: Icons.attach_money,
      ),
    ],
  ),
  AdminNavGroup(
    title: 'User Management',
    items: [
      AdminNavItem(
        path: '/creators',
        label: 'Creators',
        icon: Icons.people_outline,
      ),
      AdminNavItem(
        path: '/brands',
        label: 'Brands & Agencies',
        icon: Icons.business_outlined,
      ),
    ],
  ),
  AdminNavGroup(
    title: 'Verification Queue',
    items: [
      AdminNavItem(
        path: '/verification',
        label: 'Verification Queue',
        icon: Icons.verified_outlined,
      ),
      AdminNavItem(
        path: '/verification/brands',
        label: 'Brand Review',
        icon: Icons.business_outlined,
      ),
      AdminNavItem(
        path: '/verification/creators',
        label: 'Creator Review',
        icon: Icons.people_outline,
      ),
    ],
  ),
  AdminNavGroup(
    title: 'Campaigns',
    items: [
      AdminNavItem(
        path: '/campaigns',
        label: 'All Campaigns',
        icon: Icons.campaign_outlined,
      ),
      AdminNavItem(
        path: '/campaigns/review',
        label: 'Under Review',
        icon: Icons.hourglass_top_outlined,
      ),
      AdminNavItem(
        path: '/moderation',
        label: 'Content Moderation',
        icon: Icons.shield_outlined,
      ),
      AdminNavItem(
        path: '/fraud',
        label: 'Fraud Detection',
        icon: Icons.gpp_maybe_outlined,
      ),
    ],
  ),
  AdminNavGroup(
    title: 'Finance',
    items: [
      AdminNavItem(
        path: '/payments',
        label: 'Payments',
        icon: Icons.payments_outlined,
      ),
      AdminNavItem(
        path: '/refunds',
        label: 'Refund Requests',
        icon: Icons.undo_outlined,
      ),
      AdminNavItem(
        path: '/invoices',
        label: 'Invoices',
        icon: Icons.receipt_long_outlined,
      ),
    ],
  ),
  AdminNavGroup(
    title: 'Outreach',
    items: [
      AdminNavItem(
        path: '/outreach-leads',
        label: 'Creator Outreach Leads',
        icon: Icons.link_outlined,
      ),
      AdminNavItem(
        path: '/brand-outreach-leads',
        label: 'Brand Outreach Leads',
        icon: Icons.groups_outlined,
      ),
    ],
  ),
  AdminNavGroup(
    title: 'Trust & Safety',
    items: [
      AdminNavItem(
        path: '/trust-safety',
        label: 'Trust & Safety',
        icon: Icons.gpp_good_outlined,
      ),
    ],
  ),
  AdminNavGroup(
    title: 'System',
    items: [
      AdminNavItem(
        path: '/support',
        label: 'Support Tickets',
        icon: Icons.support_agent_outlined,
      ),
      AdminNavItem(
        path: '/broadcast',
        label: 'Broadcast Message',
        icon: Icons.campaign_outlined,
      ),
      AdminNavItem(
        path: '/roles',
        label: 'Role Management',
        icon: Icons.admin_panel_settings_outlined,
      ),
      AdminNavItem(
        path: '/audit',
        label: 'Audit Logs',
        icon: Icons.history_outlined,
      ),
      AdminNavItem(
        path: '/settings',
        label: 'System Settings',
        icon: Icons.settings_outlined,
      ),
    ],
  ),
];

/// The single sidebar item path that best matches [location] — the longest
/// matching prefix among every nav item, so a detail route like
/// `/support/AbC123` resolves to its parent section (`/support`) rather than
/// matching nothing. Shared between the sidebar (which nav item to
/// highlight) and the router (which permission a staff account needs to see
/// this location) so the two never disagree with each other.
String? navItemPathFor(String location) {
  String? best;
  for (final item in adminNavGroups.expand((group) => group.items)) {
    final matches =
        location == item.path || location.startsWith('${item.path}/');
    if (matches && (best == null || item.path.length > best.length)) {
      best = item.path;
    }
  }
  return best;
}

/// The first sidebar path (in `adminNavGroups` order) a staff account is
/// permitted to see, given its permission map — `null` if none are granted.
String? firstAllowedPath(Map<String, bool> permissions) {
  for (final item in adminNavGroups.expand((group) => group.items)) {
    if (permissions[item.path] == true) return item.path;
  }
  return null;
}
