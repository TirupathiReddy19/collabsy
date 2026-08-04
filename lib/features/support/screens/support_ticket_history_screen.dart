import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/support_chat.dart';
import '../models/support_chat_status.dart';
import '../providers/support_chat_providers.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _fmtDate(DateTime? time) {
  if (time == null) return '—';
  return '${_months[time.month - 1]} ${time.day}, ${time.year}';
}

/// Every support ticket the signed-in user has ever opened, newest first —
/// resolved ones stay here as history instead of disappearing.
class SupportTicketHistoryScreen extends ConsumerWidget {
  const SupportTicketHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final ticketsAsync = user == null
        ? const AsyncValue<List<SupportChat>>.data([])
        : ref.watch(userTicketsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Your Tickets')),
      body: SafeArea(
        child: ticketsAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, _) =>
              const Center(child: Text("Couldn't load your tickets.")),
          data: (tickets) {
            if (tickets.isEmpty) {
              return const Center(
                child: EmptyState(
                  icon: Icons.support_agent_outlined,
                  title: 'No tickets yet',
                  subtitle: "You haven't contacted support before.",
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              itemCount: tickets.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) =>
                  _TicketRow(ticket: tickets[index]),
            );
          },
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.ticket});

  final SupportChat ticket;

  @override
  Widget build(BuildContext context) {
    final resolved = ticket.status == SupportChatStatus.resolved;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => context.push(AppRoutes.supportChatPath(ticket.id)),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.card),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket #${ticket.id}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      ticket.lastMessage?.isNotEmpty == true
                          ? ticket.lastMessage!
                          : 'No messages yet',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _fmtDate(ticket.createdAt),
                      style: AppTextStyles.micro.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (resolved ? AppColors.success : AppColors.info)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  resolved ? 'Resolved' : 'Open',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: resolved ? AppColors.success : AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
