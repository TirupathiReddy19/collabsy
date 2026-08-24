import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../features/brand/models/brand_profile.dart';
import '../../features/brand/providers/brand_profile_providers.dart';
import '../../features/campaigns/models/campaign.dart';
import '../../features/campaigns/models/campaign_status.dart';
import '../../features/campaigns/providers/campaigns_providers.dart';
import '../../features/creator/models/creator_profile.dart';
import '../../features/creator/providers/creator_profile_providers.dart';
import '../../features/support/models/support_chat.dart';
import '../../features/support/models/support_chat_status.dart';
import '../../features/support/models/support_message.dart';
import '../../features/support/providers/support_chat_providers.dart';
import '../../shared/models/user_role.dart';
import '../../shared/models/verification_status.dart';
import '../providers/admin_analytics_providers.dart';
import '../providers/admin_dashboard_providers.dart';
import '../widgets/admin_analytics_charts.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_top_bar.dart';
import '../theme/admin_colors.dart';

const _overdueThreshold = Duration(minutes: 30);

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

String _fmtDate(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}, ${date.year}';

bool _isOverdue(SupportChat chat) {
  if (chat.status != SupportChatStatus.open) return false;
  if (chat.lastMessageSenderRole != SupportSenderRole.user) return false;
  final lastMessageAt = chat.lastMessageAt;
  if (lastMessageAt == null) return false;
  return DateTime.now().difference(lastMessageAt) > _overdueThreshold;
}

bool _inRange(DateTime? value, DateTime start, DateTime endExclusive) {
  if (value == null) return false;
  return !value.isBefore(start) && value.isBefore(endExclusive);
}

/// Phase 2's first real screen — platform-wide counts pulled live from
/// Firestore. Deliberately no GMV/revenue tiles here: there's no
/// wallet/financial feature anywhere in the app yet.
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _end = DateTime(today.year, today.month, today.day);
    // Trailing 14 days — matches the range these charts showed before the
    // date picker existed, so the default view is unchanged.
    _start = _end.subtract(const Duration(days: 13));
  }

  DateTime get _endExclusive => _end.add(const Duration(days: 1));

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: _end,
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _end,
      firstDate: _start,
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _end = picked);
  }

  @override
  Widget build(BuildContext context) {
    final creators = ref.watch(totalCreatorsCountProvider);
    final brands = ref.watch(totalBrandsCountProvider);
    final activeCampaigns = ref.watch(activeCampaignsCountProvider);
    final applications = ref.watch(totalApplicationsCountProvider);

    // Same client-side filtering already used by the Verification Queue
    // landing page and the Support Tickets screen — reused here so the
    // Dashboard surfaces what needs attention without the admin having to
    // navigate into each section first.
    final pendingCreators =
        (ref.watch(creatorDirectoryProvider).value ?? <CreatorProfile>[])
            .where((p) => p.verificationStatus == VerificationStatus.pending)
            .length;
    final pendingBrands =
        (ref.watch(brandDirectoryProvider).value ?? <BrandProfile>[])
            .where((p) => p.verificationStatus == VerificationStatus.pending)
            .length;
    final pendingCampaigns =
        (ref.watch(allCampaignsProvider).value ?? <Campaign>[])
            .where((c) => c.status == CampaignStatus.underReview)
            .length;
    final supportChats =
        ref.watch(allSupportChatsProvider).value ?? <SupportChat>[];
    final overdueTickets = supportChats.where(_isOverdue).length;
    final needsAttention =
        pendingCreators + pendingBrands + pendingCampaigns + overdueTickets >
        0;

    // "Needs your attention" and "Platform overview" are deliberately
    // all-time/current-state snapshots (what needs action right now, how
    // big the platform is) — the date range below only scopes the
    // time-series sections (Support Tickets, Platform Analytics).
    final ticketsInRange = supportChats
        .where(
          (c) =>
              _inRange(c.createdAt, _start, _endExclusive) ||
              (c.status == SupportChatStatus.resolved &&
                  _inRange(c.lastMessageAt, _start, _endExclusive)),
        )
        .toList();

    final signups = ref.watch(allUserSignupsProvider);
    final activity = ref.watch(allDailyActivityProvider);
    final roleByUserId = <String, UserRole?>{
      for (final s in signups.value ?? const []) s.userId: s.role,
    };
    final days = List.generate(
      _endExclusive.difference(_start).inDays,
      (i) => _start.add(Duration(days: i)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminTopBar(
          title: 'Dashboard',
          subtitle: 'Platform overview at a glance',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (needsAttention) ...[
                  Text('Needs your attention', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.4,
                    children: [
                      if (pendingCreators > 0)
                        AdminStatCard(
                          label: 'Creators Pending Review',
                          value: '$pendingCreators',
                          icon: Icons.people_outline,
                          iconColor: AppColors.info,
                          onTap: () => context.go('/verification/creators'),
                        ),
                      if (pendingBrands > 0)
                        AdminStatCard(
                          label: 'Brands Pending Review',
                          value: '$pendingBrands',
                          icon: Icons.business_outlined,
                          iconColor: AppColors.info,
                          onTap: () => context.go('/verification/brands'),
                        ),
                      if (pendingCampaigns > 0)
                        AdminStatCard(
                          label: 'Campaigns Pending Review',
                          value: '$pendingCampaigns',
                          icon: Icons.campaign_outlined,
                          iconColor: AppColors.info,
                          onTap: () => context.go('/campaigns/review'),
                        ),
                      if (overdueTickets > 0)
                        AdminStatCard(
                          label: 'Overdue Support Tickets',
                          value: '$overdueTickets',
                          icon: Icons.support_agent_outlined,
                          iconColor: AppColors.error,
                          onTap: () => context.go('/support'),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                Container(
                  padding: const EdgeInsets.all(AppSpacing.card),
                  decoration: BoxDecoration(
                    color: AdminColors.surface(context),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AdminColors.border(context)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Showing Support Tickets and Platform Analytics for:',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AdminColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickStart,
                          icon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                          ),
                          label: Text('From: ${_fmtDate(_start)}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickEnd,
                          icon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                          ),
                          label: Text('To: ${_fmtDate(_end)}'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Support Tickets',
                        style: AppTextStyles.titleLarge,
                      ),
                    ),
                    // IntrinsicWidth: a Material button as a bare Row child
                    // can be handed an infinite-width constraint and crash
                    // the whole screen's layout — same fix as AdminTopBar's
                    // `actions` slot.
                    IntrinsicWidth(
                      child: TextButton(
                        onPressed: () => context.go('/support'),
                        child: const Text('View all tickets'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AdminStatCard(
                        label: 'From Creators',
                        value: ticketsInRange
                            .where((c) => c.userRole == UserRole.creator)
                            .length
                            .toString(),
                        icon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AdminStatCard(
                        label: 'From Brands',
                        value: ticketsInRange
                            .where((c) => c.userRole == UserRole.brand)
                            .length
                            .toString(),
                        icon: Icons.business_outlined,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AdminStatCard(
                        label: 'Open',
                        value: ticketsInRange
                            .where((c) => c.status == SupportChatStatus.open)
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
                        value: ticketsInRange
                            .where(
                              (c) => c.status == SupportChatStatus.resolved,
                            )
                            .length
                            .toString(),
                        icon: Icons.check_circle_outline,
                        iconColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Platform Analytics',
                        style: AppTextStyles.titleLarge,
                      ),
                    ),
                    IntrinsicWidth(
                      child: TextButton(
                        onPressed: () => context.go('/analytics'),
                        child: const Text('View full analytics'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text('New signups', style: AppTextStyles.titleSmall),
                const SizedBox(height: 8),
                AdminCard(
                  child: signups.when(
                    data: (data) =>
                        DailySignupsChart(signups: data, days: days),
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (error, _) => Text('Failed to load: $error'),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Active users', style: AppTextStyles.titleSmall),
                const SizedBox(height: 8),
                AdminCard(
                  child: activity.when(
                    data: (data) => DailyActiveUsersChart(
                      activity: data,
                      roleByUserId: roleByUserId,
                      days: days,
                    ),
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (error, _) => Text('Failed to load: $error'),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Platform overview', style: AppTextStyles.titleLarge),
                const SizedBox(height: AppSpacing.md),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.4,
                  children: [
                    AdminStatCard(
                      label: 'Total Creators',
                      value: _valueOf(creators),
                      icon: Icons.people_outline,
                    ),
                    AdminStatCard(
                      label: 'Total Brands',
                      value: _valueOf(brands),
                      icon: Icons.business_outlined,
                      iconColor: Colors.blue,
                    ),
                    AdminStatCard(
                      label: 'Active Campaigns',
                      value: _valueOf(activeCampaigns),
                      icon: Icons.campaign_outlined,
                      iconColor: Colors.purple,
                    ),
                    AdminStatCard(
                      label: 'Total Applications',
                      value: _valueOf(applications),
                      icon: Icons.assignment_outlined,
                      iconColor: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _valueOf(AsyncValue<int> value) => value.when(
    data: (count) => '$count',
    loading: () => '—',
    error: (_, _) => '!',
  );
}
