import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/chat_time_format.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/staggered_fade_in.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/models/verification_status.dart';
import '../../../shared/utils/creator_display_name.dart';
import '../../auth/providers/auth_providers.dart';
import '../../blocking/providers/blocking_providers.dart';
import '../../blocking/widgets/report_user_sheet.dart';
import '../../brand/providers/brand_profile_providers.dart';
import '../../campaigns/providers/campaigns_providers.dart';
import '../../creator/providers/creator_profile_providers.dart';
import '../../settings/providers/instagram_providers.dart';
import '../providers/chat_providers.dart';

class ChatConversationScreen extends ConsumerStatefulWidget {
  const ChatConversationScreen({super.key, required this.chatId});

  final String chatId;

  @override
  ConsumerState<ChatConversationScreen> createState() =>
      _ChatConversationScreenState();
}

class _ChatConversationScreenState
    extends ConsumerState<ChatConversationScreen> {
  final _textController = TextEditingController();
  String? _pendingCampaignId;

  @override
  void initState() {
    super.initState();
    // A starter draft stashed by whichever screen navigated here (e.g.
    // "Message brand" on campaign detail) — pre-fills the input box for the
    // user to edit or send as-is, and carries the campaignId (if any) so
    // the ONE message that gets sent bundles both the note and a tappable
    // campaign-details link in the same bubble. Reading it is fine here,
    // but clearing it is a provider write and has to wait until after this
    // build (see the post-frame callback below) — Riverpod disallows
    // modifying a provider during initState.
    final draft = ref.read(pendingChatDraftProvider);
    if (draft != null) {
      _textController.text = draft.text;
      _pendingCampaignId = draft.campaignId;
    }
    // Marked read once on opening — good enough for now; re-marking on
    // every new message that arrives while already viewing isn't needed
    // for this first pass.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (draft != null) {
        ref.read(pendingChatDraftProvider.notifier).set(null);
      }
      final isCreator =
          ref.read(currentProfileProvider).value?.role == UserRole.creator;
      ref
          .read(chatControllerProvider.notifier)
          .markRead(chatId: widget.chatId, isCreator: isCreator);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _callPhone(String phone) async {
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  Future<void> _block(String otherUserId, UserRole otherRole) async {
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
    if (!mounted) return;
    await ref
        .read(blockingControllerProvider.notifier)
        .block(blockedId: otherUserId, blockedRole: otherRole);
    if (!mounted) return;
    if (ref.read(blockingControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't block this user.");
      return;
    }
    AppSnackbar.showSuccess(context, 'User blocked.');
  }

  Future<void> _unblock(String otherUserId) async {
    await ref.read(blockingControllerProvider.notifier).unblock(otherUserId);
    if (!mounted) return;
    if (ref.read(blockingControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't unblock this user.");
      return;
    }
    AppSnackbar.showSuccess(context, 'User unblocked.');
  }

  Future<void> _report(
    String otherUserId,
    UserRole otherRole,
    String? otherName,
  ) async {
    await ReportUserSheet.show(
      context,
      reportedId: otherUserId,
      reportedRole: otherRole,
      reportedName: otherName,
      chatId: widget.chatId,
    );
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    final campaignId = _pendingCampaignId;
    _pendingCampaignId = null;
    await ref
        .read(chatControllerProvider.notifier)
        .sendMessage(chatId: widget.chatId, text: text, campaignId: campaignId);
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatByIdProvider(widget.chatId));
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final myUid = ref.watch(authRepositoryProvider).currentUser?.uid;
    final isCreator =
        ref.watch(currentProfileProvider).value?.role == UserRole.creator;
    final chat = chatAsync.value;
    final otherUserId = chat == null
        ? null
        : (isCreator ? chat.brandId : chat.creatorId);
    final otherRole = isCreator ? UserRole.brand : UserRole.creator;
    final isBlocked = otherUserId == null
        ? false
        : ref.watch(isBlockedEitherWayProvider(otherUserId)).value ?? false;
    final iBlockedThem = otherUserId == null
        ? false
        : ref
                  .watch(myBlockedUsersProvider)
                  .value
                  ?.any((block) => block.blockedId == otherUserId) ??
              false;
    // Never trust `chat.creatorName`'s stored snapshot on its own — an
    // application/chat created before the Instagram-name fallback existed
    // (or before the creator connected Instagram at all) can have a stale
    // generic name baked in forever otherwise. Recomputing live means it
    // self-heals. Shared by the title, the block/report menu, and the
    // "can't message" notice, so they never disagree with each other.
    final otherName = chat == null
        ? null
        : (isCreator
              ? chat.brandName
              : creatorDisplayName(
                  ref
                      .watch(appUserProfileByIdProvider(chat.creatorId))
                      .value
                      ?.displayName,
                  ref
                      .watch(instagramAccountForUserProvider(chat.creatorId))
                      .value,
                  fallback: chat.creatorName,
                ));

    return Scaffold(
      appBar: AppBar(
        title: chatAsync.when(
          data: (chat) {
            if (chat == null) return const Text('Chat');
            final creatorInstagram = ref
                .watch(instagramAccountForUserProvider(chat.creatorId))
                .value;
            final avatarUrl = isCreator
                ? ref
                      .watch(appUserProfileByIdProvider(chat.brandId))
                      .value
                      ?.avatarUrl
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
            // On the Creator's side, `chat.brandName` is the company name
            // (see startGeneralChat/startChatAsCreator — it's
            // `companyName ?? displayName`), which reads oddly as the sole
            // title of a conversation with a real person. Recomputed live
            // (not the stored snapshot) so a later profile edit shows up
            // immediately: the signed-up person's own name leads, with the
            // company name underneath for context.
            final brandPersonName = isCreator
                ? (ref
                          .watch(appUserProfileByIdProvider(chat.brandId))
                          .value
                          ?.displayName ??
                      otherName)
                : null;
            final brandCompanyName = isCreator
                ? (ref
                          .watch(brandProfileByIdProvider(chat.brandId))
                          .value
                          ?.companyName ??
                      otherName)
                : null;
            return InkWell(
              onTap: () => context.push(
                isCreator
                    ? AppRoutes.brandPublicProfilePath(chat.brandId)
                    : AppRoutes.creatorPublicProfilePath(chat.creatorId),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProfileAvatar(
                    avatarUrl: avatarUrl,
                    fallbackIcon: isCreator ? Icons.storefront : Icons.person,
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: isCreator
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                brandPersonName ?? 'Chat',
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (brandCompanyName != null &&
                                  brandCompanyName != brandPersonName)
                                Text(
                                  brandCompanyName,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          )
                        : Text(
                            otherName ?? 'Chat',
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  if (isVerified) ...[
                    const SizedBox(width: 4),
                    VerifiedBadge(
                      variant: isCreator
                          ? VerifiedBadgeVariant.brand
                          : VerifiedBadgeVariant.creator,
                      size: 16,
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Text('Chat'),
          error: (error, stackTrace) => const Text('Chat'),
        ),
        actions: [
          chatAsync.when(
            data: (chat) {
              final id = otherUserId;
              if (chat == null || id == null) {
                return const SizedBox.shrink();
              }
              final phone = ref
                  .watch(appUserProfileByIdProvider(id))
                  .value
                  ?.phone;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (phone != null && phone.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.call_outlined),
                      tooltip: 'Call',
                      onPressed: () => _callPhone(phone),
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'block':
                          _block(id, otherRole);
                        case 'unblock':
                          _unblock(id);
                        case 'report':
                          _report(id, otherRole, otherName);
                      }
                    },
                    itemBuilder: (context) => [
                      if (iBlockedThem)
                        const PopupMenuItem(
                          value: 'unblock',
                          child: Text('Unblock'),
                        )
                      else
                        const PopupMenuItem(
                          value: 'block',
                          child: Text('Block'),
                        ),
                      const PopupMenuItem(
                        value: 'report',
                        child: Text('Report'),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'Say hello!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  final otherAvatarUrl = chat == null
                      ? null
                      : (isCreator
                            ? ref
                                  .watch(
                                    appUserProfileByIdProvider(chat.brandId),
                                  )
                                  .value
                                  ?.avatarUrl
                            : ref
                                  .watch(
                                    instagramAccountForUserProvider(
                                      chat.creatorId,
                                    ),
                                  )
                                  .value
                                  ?.profilePictureUrl);

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final i = messages.length - 1 - index;
                      final message = messages[i];
                      final prev = i > 0 ? messages[i - 1] : null;
                      final next = i < messages.length - 1
                          ? messages[i + 1]
                          : null;
                      final mine = message.senderId == myUid;

                      // Instagram-style grouping: consecutive messages from
                      // the same sender within a few minutes sit tight
                      // together (no gap, no repeated avatar) instead of
                      // each looking like a separate exchange.
                      final sameSenderAsPrev =
                          prev != null && prev.senderId == message.senderId;
                      final closeToPrev =
                          prev?.sentAt != null &&
                          message.sentAt != null &&
                          message.sentAt!.difference(prev!.sentAt!) <
                              const Duration(minutes: 5);
                      final isFirstInGroup = !(sameSenderAsPrev && closeToPrev);

                      final sameSenderAsNext =
                          next != null && next.senderId == message.senderId;
                      final closeToNext =
                          next?.sentAt != null &&
                          message.sentAt != null &&
                          next!.sentAt!.difference(message.sentAt!) <
                              const Duration(minutes: 5);
                      final isLastInGroup = !(sameSenderAsNext && closeToNext);

                      final showSeparator =
                          message.sentAt != null &&
                          (prev?.sentAt == null ||
                              message.sentAt!.difference(prev!.sentAt!).abs() >
                                  const Duration(minutes: 30) ||
                              message.sentAt!.day != prev.sentAt!.day);

                      return StaggeredFadeIn(
                        key: ValueKey(message.id),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showSeparator)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm,
                                ),
                                child: Center(
                                  child: Text(
                                    chatSeparatorLabel(message.sentAt!),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            _MessageBubble(
                              text: message.text,
                              campaignId: message.campaignId,
                              mine: mine,
                              isCreator: isCreator,
                              isFirstInGroup: isFirstInGroup,
                              isLastInGroup: isLastInGroup,
                              showAvatar: !mine && isLastInGroup,
                              avatarUrl: otherAvatarUrl,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: LoadingIndicator()),
                error: (error, stackTrace) =>
                    const Center(child: Text("Couldn't load messages.")),
              ),
            ),
            if (isBlocked)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      iBlockedThem
                          ? "You've blocked ${otherName ?? 'this user'}."
                          : "${otherName ?? 'This user'} has blocked you.",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (iBlockedThem) ...[
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => _unblock(otherUserId),
                        child: const Text('Unblock to send messages'),
                      ),
                    ],
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // A full pill, filled, borderless composer instead of
                    // the standard AppTextField (that one's rectangular
                    // styling comes from the app-wide input theme, meant
                    // for forms — this is deliberately its own shape, the
                    // way Instagram's message box is).
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppRadius.full),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          controller: _textController,
                          minLines: 1,
                          maxLines: 5,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Message...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textHint,
                            ),
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _textController,
                      builder: (context, value, _) {
                        final hasText = value.text.trim().isNotEmpty;
                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: hasText ? 1 : 0.4,
                          child: IconButton.filled(
                            icon: const Icon(Icons.arrow_upward, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              minimumSize: const Size(44, 44),
                            ),
                            onPressed: hasText ? _send : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A single bubble containing the sender's own text plus, when
/// [campaignId] is set, a tappable "View campaign details" section right
/// underneath it in the same bubble — opens the full campaign detail
/// screen on tap, routed to whichever side (creator/brand) is viewing it.
class _MessageBubble extends ConsumerWidget {
  const _MessageBubble({
    required this.text,
    required this.campaignId,
    required this.mine,
    required this.isCreator,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.showAvatar,
    required this.avatarUrl,
  });

  final String text;
  final String? campaignId;
  final bool mine;
  final bool isCreator;

  /// Whether this is the top bubble of a run of consecutive messages from
  /// the same sender — controls the extra gap above and which corner
  /// stays sharp, Instagram-style.
  final bool isFirstInGroup;

  /// Same idea for the bottom of the run — also gates whether the little
  /// avatar renders at all (only once per run, next to the last bubble).
  final bool isLastInGroup;
  final bool showAvatar;
  final String? avatarUrl;

  static const double _avatarSlot = 28;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = mine ? AppColors.white : AppColors.textPrimary;
    const baseRadius = Radius.circular(18);
    const tightRadius = Radius.circular(4);
    final borderRadius = BorderRadius.only(
      topLeft: !mine && !isFirstInGroup ? tightRadius : baseRadius,
      bottomLeft: !mine && !isLastInGroup ? tightRadius : baseRadius,
      topRight: mine && !isFirstInGroup ? tightRadius : baseRadius,
      bottomRight: mine && !isLastInGroup ? tightRadius : baseRadius,
    );

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width * 0.78 - (mine ? 0 : _avatarSlot),
      ),
      decoration: BoxDecoration(
        color: mine ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(color: textColor),
          ),
          if (campaignId != null) ...[
            const SizedBox(height: 10),
            // Always a white card regardless of bubble color — keeps the
            // embedded campaign details readable and visually distinct
            // instead of blending into a solid-orange "mine" bubble.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.card),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: _CampaignLink(
                campaignId: campaignId!,
                isCreator: isCreator,
              ),
            ),
          ],
        ],
      ),
    );

    final avatarSlot = SizedBox(
      width: _avatarSlot,
      height: _avatarSlot,
      child: showAvatar
          ? ProfileAvatar(
              avatarUrl: avatarUrl,
              fallbackIcon: isCreator ? Icons.storefront : Icons.person,
              radius: _avatarSlot / 2,
            )
          : null,
    );

    return Padding(
      padding: EdgeInsets.only(top: isFirstInGroup ? 10 : 2, bottom: 2),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: mine
            ? bubble
            : Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [avatarSlot, const SizedBox(width: 6), bubble],
              ),
      ),
    );
  }
}

/// Always renders on a white card background (see [_MessageBubble]), so
/// text colors here are fixed regardless of whether the enclosing bubble
/// is the sender's own (orange) or the other side's.
class _CampaignLink extends ConsumerWidget {
  const _CampaignLink({required this.campaignId, required this.isCreator});

  final String campaignId;
  final bool isCreator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignAsync = ref.watch(campaignByIdProvider(campaignId));
    return InkWell(
      onTap: () => context.push(
        isCreator
            ? AppRoutes.creatorCampaignDetailPath(campaignId)
            : AppRoutes.brandCampaignDetailPath(campaignId),
      ),
      child: campaignAsync.when(
        data: (campaign) {
          if (campaign == null) {
            return Text(
              "This campaign is no longer available.",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.campaign_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      campaign.title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${campaign.compensationLabel} · ${campaign.categoriesLabel} · '
                '${campaign.timelineLabel}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View campaign details',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (error, stackTrace) => Text(
          "Couldn't load campaign details.",
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
