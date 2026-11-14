import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router_refresh_stream.dart';
import '../core/services/firebase_service.dart';
import '../features/auth/providers/auth_providers.dart';
import 'screens/marketing_board_screen.dart';
import 'screens/marketing_login_screen.dart';

const _login = '/login';
const _home = '/';
const _adminEmail = 'admin@collabsy.online';

/// Mirrors `brand_intern_router.dart`'s redirect-guard shape, but the
/// allow check has no specific permission to test — the super admin or
/// any active `staffAccounts` doc (regardless of which permissions it
/// holds) gets in, since this board is shared by the whole team working
/// the marketing plan, not gated per-section like the Admin portal.
final marketingRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final firestore = ref.watch(firestoreProvider);

  String? cachedUid;
  bool cachedAllowed = false;

  return GoRouter(
    initialLocation: _login,
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    redirect: (context, state) async {
      final user = authRepository.currentUser;
      final atLogin = state.matchedLocation == _login;

      if (user == null) {
        cachedUid = null;
        return atLogin ? null : _login;
      }

      if (user.email == _adminEmail) {
        return atLogin ? _home : null;
      }

      if (cachedUid != user.uid) {
        final doc = await firestore
            .collection('staffAccounts')
            .doc(user.uid)
            .get();
        cachedUid = user.uid;
        cachedAllowed = doc.data()?['active'] as bool? ?? false;
      }

      if (!cachedAllowed) {
        cachedUid = null;
        await authRepository.signOut();
        return _login;
      }

      if (atLogin) return _home;
      return null;
    },
    routes: [
      GoRoute(
        path: _login,
        builder: (context, state) => const MarketingLoginScreen(),
      ),
      GoRoute(
        path: _home,
        builder: (context, state) => const MarketingBoardScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text('Page Not Found'))),
  );
});
