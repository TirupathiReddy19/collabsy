import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../features/support/models/support_chat.dart';
import '../../features/support/models/support_chat_status.dart';
import '../../features/support/models/support_message.dart';
import '../../features/support/models/support_ticket_category.dart';
import '../../features/support/providers/support_chat_providers.dart';
import '../../shared/models/user_role.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_top_bar.dart';
import '../theme/admin_colors.dart';

/// A ticket is overdue once it's been open for more than 30 minutes with
/// the user's own message as the last one — i.e. support hasn't replied yet.
const _overdueThreshold = Duration(minutes: 30);

bool _isOverdue(SupportChat chat) {
  if (chat.status != SupportChatStatus.open) return false;
  if (chat.lastMessageSenderRole != SupportSenderRole.user) return false;
  final lastMessageAt = chat.lastMessageAt;
  if (lastMessageAt == null) return false;
  return DateTime.now().difference(lastMessageAt) > _overdueThreshold;
}

/// The last message was sent by the user and support hasn't opened this
/// ticket since — i.e. there's something new here nobody on our side has
/// seen yet.
bool _isUnread(SupportChat chat) {
  if (chat.lastMessageSenderRole != SupportSenderRole.user) return false;
  final lastMessageAt = chat.lastMessageAt;
  if (lastMessageAt == null) return false;
  final supportLastReadAt = chat.supportLastReadAt;
  return supportLastReadAt == null || lastMessageAt.isAfter(supportLastReadAt);
}

/// Every user's support thread — entirely separate from the
/// Creator<->Brand `chats` messaging feature. Clicking a row opens the
/// full conversation with a reply box.
class AdminSupportScreen extends ConsumerStatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  ConsumerState<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends ConsumerState<AdminSupportScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  SupportChatStatus? _statusFilter = SupportChatStatus.open;
  SupportTicketCategory? _categoryFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(allSupportChatsProvider);
    final allChatsForStats = chats.value ?? const <SupportChat>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminTopBar(
          title: 'Support Tickets',
          subtitle: 'Every Creator/Brand support conversation',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Row(
            children: [
              Expanded(
                child: AdminStatCard(
                  label: 'From Creators',
                  value: allChatsForStats
                      .where((chat) => chat.userRole == UserRole.creator)
                      .length
                      .toString(),
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AdminStatCard(
                  label: 'From Brands',
                  value: allChatsForStats
                      .where((chat) => chat.userRole == UserRole.brand)
                      .length
                      .toString(),
                  icon: Icons.business_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AdminStatCard(
                  label: 'Open',
                  value: allChatsForStats
                      .where((chat) => chat.status == SupportChatStatus.open)
                      .length
                      .toString(),
                  icon: Icons.mark_email_unread_outlined,
                  iconColor: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AdminStatCard(
                  label: 'Resolved',
                  value: allChatsForStats
                      .where(
                        (chat) => chat.status == SupportChatStatus.resolved,
                      )
                      .length
                      .toString(),
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.success,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: const InputDecoration(
              hintText: 'Search by name',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Row(
            children: [
              _StatusChip(
                label: 'All',
                selected: _statusFilter == null,
                onTap: () => setState(() => _statusFilter = null),
              ),
              const SizedBox(width: 8),
              for (final status in SupportChatStatus.values) ...[
                _StatusChip(
                  label: status.label,
                  selected: _statusFilter == status,
                  onTap: () => setState(() => _statusFilter = status),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatusChip(
                  label: 'All categories',
                  selected: _categoryFilter == null,
                  onTap: () => setState(() => _categoryFilter = null),
                ),
                const SizedBox(width: 8),
                for (final category in SupportTicketCategory.values) ...[
                  _StatusChip(
                    label: category.label,
                    selected: _categoryFilter == category,
                    onTap: () => setState(() => _categoryFilter = category),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: chats.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, _) => Center(child: Text('Failed to load: $error')),
            data: (allChats) {
              final filtered =
                  allChats.where((chat) {
                    if (_statusFilter != null && chat.status != _statusFilter) {
                      return false;
                    }
                    if (_categoryFilter != null &&
                        chat.category != _categoryFilter) {
                      return false;
                    }
                    if (_query.isEmpty) return true;
                    return chat.userName.toLowerCase().contains(
                      _query.toLowerCase(),
                    );
                  }).toList()..sort(
                    (a, b) => (b.lastMessageAt ?? DateTime(0)).compareTo(
                      a.lastMessageAt ?? DateTime(0),
                    ),
                  );

              if (filtered.isEmpty) {
                return const EmptyState(
                  icon: Icons.support_agent_outlined,
                  title: 'No support tickets found',
                  subtitle: 'Try a different search or filter.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                itemCount: filtered.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) =>
                    _SupportRow(chat: filtered[index]),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryLight,
      labelStyle: TextStyle(
        color: selected
            ? AppColors.primary
            : AdminColors.textSecondary(context),
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: selected ? AppColors.primary : AdminColors.border(context),
      ),
    );
  }
}

class _SupportRow extends StatelessWidget {
  const _SupportRow({required this.chat});

  final SupportChat chat;

  @override
  Widget build(BuildContext context) {
    final unread = _isUnread(chat);
    return Material(
      color: AdminColors.surface(context),
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        onTap: () => context.push('/support/${chat.id}'),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.card),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(
              color: unread
                  ? AdminColors.textPrimary(context)
                  : AdminColors.border(context),
              width: unread ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  chat.userRole == UserRole.brand
                      ? Icons.business_outlined
                      : Icons.person_outline,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (unread) ...[
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: AdminColors.textPrimary(context),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            chat.userName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      chat.userRole.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AdminColors.textSecondary(context),
                      ),
                    ),
                    Text(
                      'Ticket #${chat.id}',
                      style: AppTextStyles.micro.copyWith(
                        color: AdminColors.textSecondary(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  chat.lastMessage?.isNotEmpty == true
                      ? chat.lastMessage!
                      : 'No messages yet',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: unread ? AdminColors.textPrimary(context) : null,
                    fontWeight: unread ? FontWeight.w700 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_isOverdue(chat)) ...[
                const _OverdueBadge(),
                const SizedBox(width: 8),
              ],
              _StatusBadge(status: chat.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverdueBadge extends StatelessWidget {
  const _OverdueBadge();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Open for over 30 minutes with no reply yet',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 14,
              color: AppColors.error,
            ),
            const SizedBox(width: 4),
            Text(
              'Overdue',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SupportChatStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status == SupportChatStatus.open
        ? AppColors.info
        : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
