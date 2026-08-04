import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router_refresh_stream.dart';
import '../core/services/firebase_service.dart';
import '../features/auth/providers/auth_providers.dart';
import 'screens/intern_home_screen.dart';
import 'screens/intern_login_screen.dart';

const _login = '/login';
const _home = '/';
const _outreachPermission = '/outreach-leads';

/// Mirrors `admin_router.dart`'s redirect-guard shape, scoped to a single
/// permission — an intern account is just a `staffAccounts` doc with
/// `permissions: {'/outreach-leads': true}` and nothing else, created the
/// exact same way as any other staff account via the Admin portal's Role
/// Management screen. There's no sidebar/shell here — this app shows
/// exactly one screen, nothing else.
final internRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final firestore = ref.watch(firestoreProvider);

  // Fetched once per uid and cached for the session, same convention as
  // the Admin router's `cachedPermissions`.
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

      if (cachedUid != user.uid) {
        final doc = await firestore
            .collection('staffAccounts')
            .doc(user.uid)
            .get();
        final data = doc.data();
        cachedUid = user.uid;
        final active = data?['active'] as bool? ?? false;
        final permissions = Map<String, bool>.from(
          (data?['permissions'] as Map?) ?? const {},
        );
        cachedAllowed = active && permissions[_outreachPermission] == true;
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
        builder: (context, state) => const InternLoginScreen(),
      ),
      GoRoute(
        path: _home,
        builder: (context, state) => const InternHomeScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text('Page Not Found'))),
  );
});
