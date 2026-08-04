import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../models/audit_log.dart';
import '../providers/admin_audit_log_providers.dart';
import '../widgets/admin_row_skeleton.dart';
import '../widgets/admin_top_bar.dart';
import '../theme/admin_colors.dart';

/// A permanent, read-only history of every admin decision — campaign and
/// brand approve/reject actions. Never editable (see `firestore.rules`);
/// this screen only ever reads.
class AdminAuditLogsScreen extends ConsumerWidget {
  const AdminAuditLogsScreen({super.key});

  static const _months = [
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

  static String _fmt(DateTime? time) {
    if (time == null) return '—';
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '${_months[time.month - 1]} ${time.day}, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(allAuditLogsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminTopBar(
          title: 'Audit Logs',
          subtitle:
              'Every campaign/brand approval decision, permanently recorded',
        ),
        Expanded(
          child: logs.when(
            loading: () => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.md,
              ),
              child: AdminListSkeleton(
                rowBuilder: (_) => const AdminIconRowSkeleton(),
              ),
            ),
            error: (error, _) => Center(child: Text('Failed to load: $error')),
            data: (entries) {
              if (entries.isEmpty) {
                return const EmptyState(
                  icon: Icons.history,
                  title: 'No decisions logged yet',
                  subtitle:
                      'Approving or rejecting a campaign or brand will show '
                      'up here.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.md,
                ),
                itemCount: entries.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => StaggeredFadeIn(
                  key: ValueKey(
                    '${entries[index].targetId}-'
                    '${entries[index].timestamp}-$index',
                  ),
                  delay: Duration(milliseconds: (index * 40).clamp(0, 400)),
                  child: _LogRow(entry: entries[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.entry});

  final AuditLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = entry.action.isApproval ? AppColors.success : AppColors.error;
    final route = entry.action.routeFor(entry.targetId);

    return Material(
      color: AdminColors.surface(context),
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        onTap: route == null ? null : () => context.push(route),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.card),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: AdminColors.border(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(entry.action.icon, size: 18, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.action.label(entry.targetName),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      entry.actorEmail,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AdminColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                AdminAuditLogsScreen._fmt(entry.timestamp),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AdminColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
