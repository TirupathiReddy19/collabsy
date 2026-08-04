import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../shared/models/user_role.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/app_notification.dart';
import '../providers/notifications_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  void _open(BuildContext context, WidgetRef ref, AppNotification item) {
    ref.read(notificationControllerProvider.notifier).markRead(item.id);
    if (item.referenceId == null) return;
    final isCreator =
        ref.read(currentProfileProvider).value?.role == UserRole.creator;
    switch (item.referenceType) {
      case 'campaign':
        context.push(
          isCreator
              ? AppRoutes.creatorCampaignDetailPath(item.referenceId!)
              : AppRoutes.brandCampaignDetailPath(item.referenceId!),
        );
      case 'chat':
        context.push(AppRoutes.chatDetailPath(item.referenceId!));
      case 'brand':
        // Only ever sent to the brand's own account (admin verification
        // decisions) — always their own profile, never someone else's.
        context.go(AppRoutes.brandAccount);
      case 'creator':
        // Only ever sent to the creator's own account (admin verification
        // decisions) — always their own profile, never someone else's.
        context.go(AppRoutes.creatorProfile);
      case 'support':
        // `referenceId` is the ticket id for support-reply notifications.
        context.push(AppRoutes.supportChatPath(item.referenceId!));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(myNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(notificationControllerProvider.notifier).markAllRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: SafeArea(
        child: notificationsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: EmptyState(
                  icon: Icons.notifications_none,
                  title: 'No notifications yet',
                  subtitle:
                      "You'll see updates on campaigns, applications, "
                      'and messages here.',
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  color: item.read ? null : AppColors.primaryLight,
                  child: ListTile(
                    leading: Icon(item.type.icon, color: AppColors.primary),
                    title: Text(item.title, style: AppTextStyles.titleSmall),
                    subtitle: Text(item.body, style: AppTextStyles.bodySmall),
                    onTap: () => _open(context, ref, item),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, stackTrace) => const Center(
            child: EmptyState(
              icon: Icons.error_outline,
              title: "Couldn't load notifications",
            ),
          ),
        ),
      ),
    );
  }
}
