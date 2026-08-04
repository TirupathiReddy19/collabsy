import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../shared/models/user_role.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/block.dart';
import '../providers/blocking_providers.dart';

class BlockedAccountsScreen extends ConsumerWidget {
  const BlockedAccountsScreen({super.key});

  Future<void> _unblock(
    BuildContext context,
    WidgetRef ref,
    Block block,
  ) async {
    await ref
        .read(blockingControllerProvider.notifier)
        .unblock(block.blockedId);
    if (!context.mounted) return;
    if (ref.read(blockingControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't unblock this user.");
      return;
    }
    AppSnackbar.showSuccess(context, 'User unblocked.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync = ref.watch(myBlockedUsersProvider);
    final isLoading = ref.watch(blockingControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Blocked accounts')),
      body: SafeArea(
        child: blocksAsync.when(
          data: (blocks) {
            if (blocks.isEmpty) {
              return const EmptyState(
                icon: Icons.block,
                title: 'No blocked accounts',
                subtitle: "Users you've blocked will show up here.",
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              itemCount: blocks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final block = blocks[index];
                return _BlockedAccountTile(
                  block: block,
                  isLoading: isLoading,
                  onUnblock: () => _unblock(context, ref, block),
                );
              },
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, stackTrace) =>
              const Center(child: Text("Couldn't load blocked accounts.")),
        ),
      ),
    );
  }
}

class _BlockedAccountTile extends ConsumerWidget {
  const _BlockedAccountTile({
    required this.block,
    required this.isLoading,
    required this.onUnblock,
  });

  final Block block;
  final bool isLoading;
  final VoidCallback onUnblock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref
        .watch(appUserProfileByIdProvider(block.blockedId))
        .value;
    final name = profile?.displayName ?? 'Unknown user';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ProfileAvatar(
            avatarUrl: profile?.avatarUrl,
            fallbackIcon: block.blockedRole == UserRole.creator
                ? Icons.person
                : Icons.storefront,
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleSmall),
                Text(
                  block.blockedRole == UserRole.creator ? 'Creator' : 'Brand',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: isLoading ? null : onUnblock,
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }
}
