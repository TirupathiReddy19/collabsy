import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart' hide Block;

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/blocking/models/block.dart';
import '../../features/blocking/models/user_report.dart';
import '../../features/settings/providers/instagram_providers.dart';
import '../../shared/models/user_role.dart';
import '../providers/admin_blocking_providers.dart';
import '../theme/admin_colors.dart';
import '../utils/creator_display_name.dart';
import '../widgets/admin_row_skeleton.dart';
import '../widgets/admin_top_bar.dart';

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

String _fmt(DateTime? time) {
  if (time == null) return '—';
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour < 12 ? 'AM' : 'PM';
  return '${_months[time.month - 1]} ${time.day}, $hour:$minute $period';
}

String _detailPathFor(String userId, UserRole role) =>
    role == UserRole.creator ? '/creators/$userId' : '/brands/$userId';

/// Resolves any user id to a real name — Instagram-name fallback for
/// creators (see `creatorDisplayNameFor`; a phone/OTP signup never
/// collects a display name, so Instagram is usually the only identity a
/// creator has), display name/email/phone fallback for brands.
String _resolveName(WidgetRef ref, String userId, UserRole role) {
  final user = ref.watch(appUserProfileByIdProvider(userId)).value;
  if (user == null) return userId;
  if (role == UserRole.creator) {
    final instagram = ref.watch(instagramAccountForUserProvider(userId)).value;
    return creatorDisplayNameFor(user, instagram);
  }
  return user.displayName?.isNotEmpty == true
      ? user.displayName!
      : (user.email ?? user.phone ?? 'Brand');
}

/// Combined Trust & Safety section — who has blocked whom, and the
/// moderation queue of user reports. Both read from collections that are
/// otherwise invisible to admin (blocking/reporting only writes from the
/// mobile app), gated behind a single `/trust-safety` staff permission.
class AdminTrustSafetyScreen extends StatelessWidget {
  const AdminTrustSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminTopBar(
            title: 'Trust & Safety',
            subtitle:
                'Block relationships and user reports across the platform',
          ),
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Blocked accounts'),
              Tab(text: 'Reports'),
            ],
          ),
          const Expanded(
            child: TabBarView(children: [_BlocksTab(), _ReportsTab()]),
          ),
        ],
      ),
    );
  }
}

class _BlocksTab extends ConsumerWidget {
  const _BlocksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync = ref.watch(allBlocksProvider);

    return blocksAsync.when(
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
      data: (blocks) {
        if (blocks.isEmpty) {
          return const EmptyState(
            icon: Icons.block,
            title: 'No blocks yet',
            subtitle: 'Users who block each other will show up here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.md,
          ),
          itemCount: blocks.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) => StaggeredFadeIn(
            key: ValueKey(blocks[index].id),
            delay: Duration(milliseconds: (index * 40).clamp(0, 400)),
            child: _BlockRow(block: blocks[index]),
          ),
        );
      },
    );
  }
}

class _BlockRow extends ConsumerWidget {
  const _BlockRow({required this.block});

  final Block block;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockerName = _resolveName(ref, block.blockerId, block.blockerRole);
    final blockedName = _resolveName(ref, block.blockedId, block.blockedRole);

    return Material(
      color: AdminColors.surface(context),
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        onTap: () =>
            context.push(_detailPathFor(block.blockerId, block.blockerRole)),
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
                  color: AdminColors.textSecondary(
                    context,
                  ).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.block, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$blockerName (${block.blockerRole.label}) blocked '
                      '$blockedName (${block.blockedRole.label})',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _fmt(block.createdAt),
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

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(allReportsProvider);
    final isLoading = ref.watch(adminBlockingControllerProvider).isLoading;

    return reportsAsync.when(
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
      data: (reports) {
        if (reports.isEmpty) {
          return const EmptyState(
            icon: Icons.flag_outlined,
            title: 'No reports yet',
            subtitle: 'Reports submitted by users will show up here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.md,
          ),
          itemCount: reports.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) => StaggeredFadeIn(
            key: ValueKey(reports[index].id),
            delay: Duration(milliseconds: (index * 40).clamp(0, 400)),
            child: _ReportRow(report: reports[index], isLoading: isLoading),
          ),
        );
      },
    );
  }
}

class _ReportRow extends ConsumerWidget {
  const _ReportRow({required this.report, required this.isLoading});

  final UserReport report;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reporterName = _resolveName(
      ref,
      report.reporterId,
      report.reporterRole,
    );
    final isOpen = report.status == 'open';

    return Material(
      color: AdminColors.surface(context),
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        onTap: () => context.push(
          _detailPathFor(report.reportedId, report.reportedRole),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.card),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: AdminColors.border(context)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$reporterName reported '
                      '${report.reportedName ?? report.reportedId}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.reason.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AdminColors.textSecondary(context),
                      ),
                    ),
                    if ((report.details ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        report.details!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AdminColors.textSecondary(context),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      _fmt(report.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AdminColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              if (isOpen)
                OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () => ref
                            .read(adminBlockingControllerProvider.notifier)
                            .markReportReviewed(report.id),
                  child: const Text('Mark reviewed'),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AdminColors.border(context)),
                  ),
                  child: Text(
                    'Reviewed',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AdminColors.textSecondary(context),
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
