import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/notifications_providers.dart';

/// Bell icon with an unread-count badge — used as an AppBar action on both
/// portals' home screens.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsCountProvider);

    return IconButton(
      onPressed: () => context.push(AppRoutes.notifications),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text('$unread'),
        backgroundColor: AppColors.error,
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
