import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/theme_mode_providers.dart';
import '../core/theme/app_theme.dart';
import 'intern_router.dart';

class InternApp extends ConsumerWidget {
  const InternApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(internRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Collabsy Outreach',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
