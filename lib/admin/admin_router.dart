import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router_refresh_stream.dart';
import '../core/services/firebase_service.dart';
import '../features/auth/providers/auth_providers.dart';
import '../shared/models/verification_status.dart';
import '../features/campaigns/models/campaign_status.dart';
import 'models/admin_nav_item.dart';
import 'providers/admin_auth_providers.dart';
import 'screens/admin_analytics_screen.dart';
import 'screens/admin_audit_logs_screen.dart';
import 'screens/admin_brand_detail_screen.dart';
import 'screens/admin_brand_outreach_leads_screen.dart';
import 'screens/admin_broadcast_screen.dart';
import 'screens/admin_brands_screen.dart';
import 'screens/admin_campaign_detail_screen.dart';
import 'screens/admin_campaigns_screen.dart';
import 'screens/admin_coming_soon_screen.dart';
import 'screens/admin_creator_detail_screen.dart';
import 'screens/admin_creators_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_deletion_requests_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_no_access_screen.dart';
import 'screens/admin_outreach_leads_screen.dart';
import 'screens/admin_reports_screen.dart';
import 'screens/admin_role_management_screen.dart';
import 'screens/admin_settings_screen.dart';
import 'screens/admin_shell.dart';
import 'screens/admin_support_chat_detail_screen.dart';
import 'screens/admin_support_screen.dart';
import 'screens/admin_trust_safety_screen.dart';
import 'screens/admin_verification_queue_screen.dart';

const _login = '/login';
const _dashboard = '/dashboard';
const _noAccess = '/no-access';

/// Cross-fades (with a small upward slide) between sidebar sections
/// instead of GoRouter's default hard cut — used for every route inside
/// the `ShellRoute` below, so switching sections feels like one continuous
/// surface rather than a page reload.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 160),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Screens actually built so far — every other sidebar path falls back to
/// [AdminComingSoonScreen] so the whole sidebar stays navigable.
final Map<String, GoRouterWidgetBuilder> _builtScreens = {
  _dashboard: (context, state) => const AdminDashboardScreen(),
  '/analytics': (context, state) => const AdminAnalyticsScreen(),
  '/reports': (context, state) => const AdminReportsScreen(),
  '/creators': (context, state) => const AdminCreatorsScreen(),
  '/brands': (context, state) => const AdminBrandsScreen(),
  '/verification': (context, state) => const AdminVerificationQueueScreen(),
  '/verification/brands': (context, state) =>
      const AdminBrandsScreen.locked(status: VerificationStatus.pending),
  '/verification/creators': (context, state) =>
      const AdminCreatorsScreen.locked(status: VerificationStatus.pending),
  '/campaigns': (context, state) => const AdminCampaignsScreen(),
  '/campaigns/review': (context, state) =>
      const AdminCampaignsScreen.locked(status: CampaignStatus.underReview),
  '/audit': (context, state) => const AdminAuditLogsScreen(),
  '/deletion-requests': (context, state) => const AdminDeletionRequestsScreen(),
  '/support': (context, state) => const AdminSupportScreen(),
  '/broadcast': (context, state) => const AdminBroadcastScreen(),
  '/roles': (context, state) => const AdminRoleManagementScreen(),
  '/outreach-leads': (context, state) => const AdminOutreachLeadsScreen(),
  '/brand-outreach-leads': (context, state) =>
      const AdminBrandOutreachLeadsScreen(),
  '/settings': (context, state) => const AdminSettingsScreen(),
  '/trust-safety': (context, state) => const AdminTrustSafetyScreen(),
};

final adminRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final firestore = ref.watch(firestoreProvider);

  // A staff account's permissions are fetched once per uid and cached here
  // for the lifetime of the session, rather than re-fetched on every single
  // navigation — reset whenever the signed-in uid changes (including on
  // sign-out).
  String? cachedUid;
  bool cachedActive = false;
  Map<String, bool> cachedPermissions = const {};

  return GoRouter(
    initialLocation: _login,
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    redirect: (context, state) async {
      // Checked directly off FirebaseAuth's synchronous `currentUser`, not
      // `isAdminProvider` — that provider reads the `authStateChanges()`
      // stream, and this callback can run before that stream's own
      // subscription has caught up to a just-completed sign-in (listener
      // ordering on the same broadcast stream isn't guaranteed), which left
      // sign-in silently stuck on the login screen. Matches the same fix
      // already applied in AdminLoginScreen and the pattern the main app's
      // router uses for this exact reason.
      final user = authRepository.currentUser;
      final atLogin = state.matchedLocation == _login;

      if (user == null) {
        cachedUid = null;
        return atLogin ? null : _login;
      }

      if (user.email == adminEmail) {
        return atLogin ? _dashboard : null;
      }

      // Staff account: fetch permissions once per uid. Unlike the
      // `isAdminProvider`-vs-`currentUser` race above, this genuinely awaits
      // a one-shot Firestore read rather than reading a possibly-stale
      // cached stream value, so it doesn't reintroduce that bug.
      if (cachedUid != user.uid) {
        final doc = await firestore
            .collection('staffAccounts')
            .doc(user.uid)
            .get();
        final data = doc.data();
        cachedUid = user.uid;
        cachedActive = data?['active'] as bool? ?? false;
        cachedPermissions = Map<String, bool>.from(
          (data?['permissions'] as Map?) ?? const {},
        );
      }

      if (!cachedActive) {
        cachedUid = null;
        await authRepository.signOut();
        return _login;
      }

      final fallback = firstAllowedPath(cachedPermissions);
      final atNoAccess = state.matchedLocation == _noAccess;

      if (atLogin || atNoAccess) {
        return fallback ?? (atNoAccess ? null : _noAccess);
      }

      // Role Management is always super-admin-only — never reachable by a
      // staff account, regardless of what its permission map says.
      final isRolesRoute =
          state.matchedLocation == '/roles' ||
          state.matchedLocation.startsWith('/roles/');
      if (isRolesRoute) {
        return fallback ?? _noAccess;
      }

      // Reports reads across data gated behind several other sections' own
      // specific permissions (Analytics, Audit Logs, Support) — rather than
      // loosen those rules, Reports is super-admin-only too, same as Roles.
      final isReportsRoute =
          state.matchedLocation == '/reports' ||
          state.matchedLocation.startsWith('/reports/');
      if (isReportsRoute) {
        return fallback ?? _noAccess;
      }

      // System Settings writes the config both outreach tools' Cloud
      // Functions read from — same super-admin-only reasoning as Reports
      // and Roles, rather than adding a new staff permission for it.
      final isSettingsRoute =
          state.matchedLocation == '/settings' ||
          state.matchedLocation.startsWith('/settings/');
      if (isSettingsRoute) {
        return fallback ?? _noAccess;
      }

      final permissionKey = navItemPathFor(state.matchedLocation);
      if (permissionKey == null || cachedPermissions[permissionKey] != true) {
        return fallback ?? _noAccess;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: _login,
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: _noAccess,
        builder: (context, state) =>
            const Scaffold(body: SafeArea(child: AdminNoAccessScreen())),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          for (final group in adminNavGroups)
            for (final item in group.items)
              GoRoute(
                path: item.path,
                pageBuilder: (context, state) => _fadePage(
                  state,
                  (_builtScreens[item.path] ??
                      (context, state) => AdminComingSoonScreen(
                        title: item.label,
                      ))(context, state),
                ),
              ),
          // Detail routes reached by clicking a row on the list screens
          // above — not sidebar destinations themselves, so they don't
          // appear in `adminNavGroups`.
          GoRoute(
            path: '/creators/:id',
            pageBuilder: (context, state) => _fadePage(
              state,
              AdminCreatorDetailScreen(creatorId: state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/brands/:id',
            pageBuilder: (context, state) => _fadePage(
              state,
              AdminBrandDetailScreen(brandId: state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/campaigns/:id',
            pageBuilder: (context, state) => _fadePage(
              state,
              AdminCampaignDetailScreen(
                campaignId: state.pathParameters['id']!,
              ),
            ),
          ),
          GoRoute(
            path: '/support/:id',
            pageBuilder: (context, state) => _fadePage(
              state,
              AdminSupportChatDetailScreen(
                ticketId: state.pathParameters['id']!,
              ),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text('Page Not Found'))),
  );
});
