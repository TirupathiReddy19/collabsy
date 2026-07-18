import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class CollabsyApp extends StatelessWidget {
  const CollabsyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Collabsy',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}