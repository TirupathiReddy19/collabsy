import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/models/verification_status.dart';
import '../../../shared/utils/creator_display_name.dart';
import '../../announcements/providers/announcements_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../brand/providers/brand_profile_providers.dart';
import '../../creator/providers/creator_profile_providers.dart';
import '../../settings/providers/instagram_providers.dart';
import '../models/chat.dart';
import '../models/chat_status.dart';
import '../providers/chat_providers.dart';

/// Messages tab shared by both portals — [myChatsProvider] already adapts
/// to whichever side (creator/brand) the signed-in user is. Split into
/// "Requests" (unsolicited/pre-acceptance contact) and "Messages"
/// (established conversations) sub-tabs.
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Messages'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _AnnouncementsCard(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _ChatSubList(status: ChatStatus.active),
                  _ChatSubList(status: ChatStatus.request),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pinned above the Requests/Messages tabs (not inside either one) — a
/// broadcast isn't a Creator<->Brand chat, so it doesn't belong to either
/// sub-tab's status filter. [myAnnouncementsProvider] already resolves to
/// the right (role-filtered) list for either side, so this renders
/// identically for Creators and Brands.
class _AnnouncementsCard extends ConsumerWidget {
  const _AnnouncementsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(myAnnouncementsProvider).value ?? const [];
    if (announcements.isEmpty) return const SizedBox.shrink();

    final unread = ref.watch(hasUnreadAnnouncementsProvider);
    final latest = announcements.first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: Card(
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.campaign_outlined, color: Colors.white),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Collabsy Team',
                style: unread
                    ? AppTextStyles.titleSmall
                    : AppTextStyles.bodyLarge,
              ),
              const SizedBox(width: 4),
              const VerifiedBadge(
                variant: VerifiedBadgeVariant.broadcast,
                size: 16,
              ),
            ],
          ),
          subtitle: Text(
            latest.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: unread
              ? const Icon(Icons.circle, size: 10, color: AppColors.primary)
              : null,
          onTap: () => context.push(AppRoutes.announcements),
        ),
      ),
    );
  }
}

class _ChatSubList extends ConsumerWidget {
  const _ChatSubList({required this.status});

  final ChatStatus status;

  bool _isUnread(Chat chat, bool isCreator) {
    if (chat.lastMessageAt == null) return false;
    final lastRead = isCreator ? chat.creatorLastReadAt : chat.brandLastReadAt;
    if (lastRead == null) return true;
    return chat.lastMessageAt!.isAfter(lastRead);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(myChatsProvider);
    final isCreator =
        ref.watch(currentProfileProvider).value?.role == UserRole.creator;

    return chatsAsync.when(
      data: (chats) {
        final filtered = chats.where((chat) => chat.status == status).toList();
        if (filtered.isEmpty) {
          return Center(
            child: EmptyState(
              icon: status == ChatStatus.request
                  ? Icons.mark_email_unread_outlined
                  : Icons.chat_bubble_outline,
              title: status == ChatStatus.request
                  ? 'No requests yet'
                  : 'No conversations yet',
              subtitle: status == ChatStatus.request
                  ? 'Messages from a new contact show up here first.'
                  : 'Accepted applications and replied requests land here.',
            ),
          );
        }
        final sorted = [...filtered]
          ..sort(
            (a, b) => (b.lastMessageAt ?? DateTime(0)).compareTo(
              a.lastMessageAt ?? DateTime(0),
            ),
          );
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          itemCount: sorted.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            return _ChatListTile(
              chat: sorted[index],
              isCreator: isCreator,
              unread: _isUnread(sorted[index], isCreator),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stackTrace) => const Center(
        child: EmptyState(
          icon: Icons.error_outline,
          title: "Couldn't load messages",
          subtitle: 'Please try again in a moment.',
        ),
      ),
    );
  }
}

class _ChatListTile extends ConsumerWidget {
  const _ChatListTile({
    required this.chat,
    required this.isCreator,
    required this.unread,
  });

  final Chat chat;
  final bool isCreator;
  final bool unread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creatorInstagram = ref
        .watch(instagramAccountForUserProvider(chat.creatorId))
        .value;
    // Never trust `chat.creatorName`'s stored snapshot on its own — an
    // application/chat created before the Instagram-name fallback existed
    // (or before the creator connected Instagram at all) can have a stale
    // generic name baked in forever otherwise. Recomputing live means it
    // self-heals.
    final otherName = isCreator
        ? chat.brandName
        : creatorDisplayName(
            ref
                .watch(appUserProfileByIdProvider(chat.creatorId))
                .value
                ?.displayName,
            creatorInstagram,
            fallback: chat.creatorName,
          );
    // On the Creator's side, `chat.brandName` is the company name (see
    // startGeneralChat/startChatAsCreator — it's `companyName ??
    // displayName`), which reads oddly as a contact's row title. Recomputed
    // live (not the stored snapshot) so a later profile edit shows up
    // immediately: the signed-up person's own name leads, company name goes
    // under it alongside the last-message preview.
    final brandPersonName = isCreator
        ? (ref.watch(appUserProfileByIdProvider(chat.brandId)).value?.displayName ??
              otherName)
        : null;
    final brandCompanyName = isCreator
        ? (ref.watch(brandProfileByIdProvider(chat.brandId)).value?.companyName ??
              otherName)
        : null;
    final showCompanyLine =
        isCreator && brandCompanyName != null && brandCompanyName != brandPersonName;
    // The other party is a Creator when I'm the Brand (Instagram-synced
    // photo), or a Brand when I'm the Creator (their manual upload, since
    // Brands have no Instagram connection).
    final avatarUrl = isCreator
        ? ref.watch(appUserProfileByIdProvider(chat.brandId)).value?.avatarUrl
        : creatorInstagram?.profilePictureUrl;
    final isVerified = isCreator
        ? ref
                  .watch(brandProfileByIdProvider(chat.brandId))
                  .value
                  ?.verificationStatus ==
              VerificationStatus.approved
        : ref
                  .watch(creatorProfileByIdProvider(chat.creatorId))
                  .value
                  ?.verificationStatus ==
              VerificationStatus.approved;

    return Card(
      child: ListTile(
        leading: GestureDetector(
          onTap: () => context.push(
            isCreator
                ? AppRoutes.brandPublicProfilePath(chat.brandId)
                : AppRoutes.creatorPublicProfilePath(chat.creatorId),
          ),
          child: ProfileAvatar(
            avatarUrl: avatarUrl,
            fallbackIcon: isCreator ? Icons.storefront : Icons.person,
            radius: 20,
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                isCreator ? (brandPersonName ?? otherName) : otherName,
                overflow: TextOverflow.ellipsis,
                style: unread
                    ? AppTextStyles.titleSmall
                    : AppTextStyles.bodyLarge,
              ),
            ),
            if (isVerified) ...[
              const SizedBox(width: 4),
              VerifiedBadge(
                variant: isCreator
                    ? VerifiedBadgeVariant.brand
                    : VerifiedBadgeVariant.creator,
                size: 14,
              ),
            ],
          ],
        ),
        isThreeLine: showCompanyLine && chat.lastMessage != null,
        subtitle: showCompanyLine
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    brandCompanyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (chat.lastMessage != null)
                    Text(
                      chat.lastMessage!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              )
            : chat.lastMessage == null
            ? null
            : Text(
                chat.lastMessage!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: unread
            ? const Icon(Icons.circle, size: 10, color: AppColors.primary)
            : null,
        onTap: () => context.push(AppRoutes.chatDetailPath(chat.id)),
      ),
    );
  }
}
