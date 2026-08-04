import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/providers/auth_providers.dart';
import 'router.dart';

class CollabsyApp extends ConsumerWidget {
  const CollabsyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Fires once per sign-in event (not per navigation) — the only signal
    // Platform Analytics has for daily active users, since there's no
    // separate analytics SDK. The write is idempotent (deterministic
    // per-user-per-day doc id), so firing more than once a day is harmless.
    ref.listen(authStateChangesProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        ref.read(authRepositoryProvider).recordDailyActivity(user.uid);
      }
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Collabsy',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
