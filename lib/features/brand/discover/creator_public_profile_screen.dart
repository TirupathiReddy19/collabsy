import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/instagram_icon.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/models/verification_status.dart';
import '../../../shared/utils/creator_display_name.dart';
import '../../blocking/providers/blocking_providers.dart';
import '../../blocking/widgets/report_user_sheet.dart';
import '../../chat/providers/chat_providers.dart';
import '../../creator/providers/creator_profile_providers.dart';
import '../../settings/models/instagram_account.dart';
import '../../settings/providers/instagram_providers.dart';

/// Read-only, Brand-facing view of a creator's profile — reached by
/// tapping a creator in Discover.
class CreatorPublicProfileScreen extends ConsumerWidget {
  const CreatorPublicProfileScreen({super.key, required this.creatorId});

  final String creatorId;

  Future<void> _message(
    BuildContext context,
    WidgetRef ref,
    String creatorName,
  ) async {
    final chatId = await ref
        .read(chatControllerProvider.notifier)
        .startGeneralChat(creatorId: creatorId, creatorName: creatorName);
    if (!context.mounted) return;
    if (ref.read(chatControllerProvider).hasError || chatId == null) {
      AppSnackbar.showError(
        context,
        "Couldn't start the chat. Please try again.",
      );
      return;
    }
    context.push(AppRoutes.chatDetailPath(chatId));
  }

  Future<void> _block(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block this user?'),
        content: const Text(
          "They won't be able to message you, and you won't be able to "
          'message them, until you unblock them from Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await ref
        .read(blockingControllerProvider.notifier)
        .block(blockedId: creatorId, blockedRole: UserRole.creator);
    if (!context.mounted) return;
    if (ref.read(blockingControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't block this user.");
      return;
    }
    AppSnackbar.showSuccess(context, 'User blocked.');
  }

  Future<void> _unblock(BuildContext context, WidgetRef ref) async {
    await ref.read(blockingControllerProvider.notifier).unblock(creatorId);
    if (!context.mounted) return;
    if (ref.read(blockingControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't unblock this user.");
      return;
    }
    AppSnackbar.showSuccess(context, 'User unblocked.');
  }

  Future<void> _report(BuildContext context, String creatorName) async {
    await ReportUserSheet.show(
      context,
      reportedId: creatorId,
      reportedRole: UserRole.creator,
      reportedName: creatorName,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(creatorProfileByIdProvider(creatorId));
    final instagramAsync = ref.watch(
      instagramAccountForUserProvider(creatorId),
    );
    final isLoading = ref.watch(chatControllerProvider).isLoading;
    // Instagram is a creator's only photo source (manual avatar upload was
    // removed for creators) — never fall back to a stale `users/{uid}.
    // avatarUrl` left over from before that change.
    final avatarUrl = instagramAsync.value?.profilePictureUrl;
    final iBlockedThem =
        ref
            .watch(myBlockedUsersProvider)
            .value
            ?.any((block) => block.blockedId == creatorId) ??
        false;
    final isBlocked =
        ref.watch(isBlockedEitherWayProvider(creatorId)).value ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'block':
                  _block(context, ref);
                case 'unblock':
                  _unblock(context, ref);
                case 'report':
                  final name = profileAsync.value == null
                      ? 'this user'
                      : creatorDisplayName(
                          profileAsync.value!.displayName,
                          instagramAsync.value,
                        );
                  _report(context, name);
              }
            },
            itemBuilder: (context) => [
              if (iBlockedThem)
                const PopupMenuItem(value: 'unblock', child: Text('Unblock'))
              else
                const PopupMenuItem(value: 'block', child: Text('Block')),
              const PopupMenuItem(value: 'report', child: Text('Report')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return const Center(child: Text('Creator not found.'));
            }
            final creatorName = creatorDisplayName(
              profile.displayName,
              instagramAsync.value,
            );
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              children: [
                ProfileAvatar(avatarUrl: avatarUrl, fallbackIcon: Icons.person),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        creatorName,
                        style: AppTextStyles.heading1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (profile.verificationStatus ==
                        VerificationStatus.approved) ...[
                      const SizedBox(width: 6),
                      const VerifiedBadge(
                        variant: VerifiedBadgeVariant.creator,
                        size: 22,
                      ),
                    ],
                  ],
                ),
                if (profile.city != null || profile.state != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      profile.city,
                      profile.state,
                    ].whereType<String>().join(', '),
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(profile.bio!, style: AppTextStyles.bodyLarge),
                ],
                instagramAsync.when(
                  data: (account) =>
                      account?.status == InstagramConnectionStatus.connected
                      ? Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: _InstagramSocialCard(account: account!),
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                ),
                if (profile.categories.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Content categories', style: AppTextStyles.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.categories
                        .map((category) => Chip(label: Text(category)))
                        .toList(),
                  ),
                ],
                if (profile.languages.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Languages', style: AppTextStyles.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.languages
                        .map((language) => Chip(label: Text(language)))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 32),
                if (isBlocked)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        iBlockedThem
                            ? "You've blocked $creatorName."
                            : '$creatorName has blocked you.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (iBlockedThem) ...[
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () => _unblock(context, ref),
                          child: const Text('Unblock to send messages'),
                        ),
                      ],
                    ],
                  )
                else
                  PrimaryButton(
                    text: 'Message',
                    icon: Icons.chat_bubble_outline,
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () => _message(context, ref, creatorName),
                  ),
              ],
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, stackTrace) =>
              const Center(child: Text("Couldn't load this creator.")),
        ),
      ),
    );
  }
}

/// The follower-count-and-link card Brands see on a Creator's public
/// profile — the actual social proof this whole Instagram integration
/// exists for.
class _InstagramSocialCard extends StatelessWidget {
  const _InstagramSocialCard({required this.account});

  final InstagramAccount account;

  String get _profileUrl => 'https://instagram.com/${account.username}';

  Future<void> _openProfile() async {
    final uri = Uri.tryParse(_profileUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _profileUrl));
    if (!context.mounted) return;
    AppSnackbar.showSuccess(context, 'Instagram link copied.');
  }

  String _formatCount(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Socials', style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _openProfile,
          child: Container(
            width: 140,
            padding: const EdgeInsets.all(AppSpacing.card),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const InstagramIcon(size: 32),
                    IconButton(
                      icon: const Icon(Icons.copy_outlined, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _copyLink(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _formatCount(account.followersCount),
                  style: AppTextStyles.titleLarge,
                ),
                Text(
                  'Followers',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
