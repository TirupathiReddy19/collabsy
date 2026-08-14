import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/website_about_screen.dart';
import 'screens/website_brands_screen.dart';
import 'screens/website_contact_screen.dart';
import 'screens/website_creators_screen.dart';
import 'screens/website_delete_account_screen.dart';
import 'screens/website_home_screen.dart';
import 'screens/website_not_found_screen.dart';
import 'screens/website_privacy_screen.dart';
import 'screens/website_terms_screen.dart';
import 'widgets/website_shell.dart';

/// Fully public — no Firebase Auth, no redirect guard, just static routes.
/// Every route lives inside one [ShellRoute] so the header/footer chrome
/// (including on /privacy and /terms) stays consistent site-wide.
final websiteRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => WebsiteShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, _) => const WebsiteHomeScreen()),
          GoRoute(
            path: '/creators',
            builder: (_, _) => const WebsiteCreatorsScreen(),
          ),
          GoRoute(path: '/brands', builder: (_, _) => WebsiteBrandsScreen()),
          GoRoute(
            path: '/about',
            builder: (_, _) => const WebsiteAboutScreen(),
          ),
          GoRoute(
            path: '/contact',
            builder: (_, _) => const WebsiteContactScreen(),
          ),
          GoRoute(
            path: '/privacy',
            builder: (_, _) => const WebsitePrivacyScreen(),
          ),
          GoRoute(
            path: '/terms',
            builder: (_, _) => const WebsiteTermsScreen(),
          ),
          GoRoute(
            path: '/delete-account',
            builder: (_, _) => const WebsiteDeleteAccountScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: SafeArea(child: WebsiteNotFoundScreen())),
  );
});
