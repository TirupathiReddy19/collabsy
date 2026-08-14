import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import 'website_router.dart';

/// Public marketing site — light theme only, no auth/theme-mode state to
/// watch (unlike the admin/intern targets).
class WebsiteApp extends ConsumerWidget {
  const WebsiteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(websiteRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Collabsy — Influencer Marketing Platform for D2C Brands',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
