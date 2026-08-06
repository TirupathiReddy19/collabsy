import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/greeting.dart';
import '../../../core/widgets/contact_links_card.dart';
import '../../../core/widgets/count_up_stat.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/profile_completeness_card.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/staggered_fade_in.dart';
import '../../../shared/utils/creator_display_name.dart';
import '../../auth/providers/auth_providers.dart';
import '../../campaigns/models/application_status.dart';
import '../../campaigns/models/campaign.dart';
import '../../campaigns/models/campaign_application.dart';
import '../../campaigns/models/compensation_type.dart';
import '../../campaigns/providers/campaigns_providers.dart';
import '../../notifications/widgets/notification_bell.dart';
import '../../settings/models/instagram_account.dart';
import '../../settings/providers/instagram_providers.dart';
import '../providers/creator_profile_providers.dart';

/// Creator portal home — the real dashboard (AI score, active campaigns,
/// earnings) lands once campaigns/wallet exist in later milestones. For now
/// this shows the real signed-in profile plus empty-state placeholders for
/// what's coming.
class CreatorHomeScreen extends ConsumerWidget {
  const CreatorHomeScreen({super.key});

  static final _cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: const BorderSide(color: AppColors.border),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final instagramAccount = ref.watch(ownInstagramAccountProvider).value;
    final applicationsAsync = ref.watch(creatorApplicationsProvider);
    final applications = applicationsAsync.value ?? const [];
    final sentCount = applications.length;
    final acceptedCount = applications
        .where(
          (a) =>
              a.status == ApplicationStatus.accepted ||
              a.status == ApplicationStatus.completed,
        )
        .length;
    final pendingCount = applications
        .where((a) => a.status == ApplicationStatus.pending)
        .length;
    final responseRate = sentCount == 0
        ? 0
        : (((sentCount - pendingCount) / sentCount) * 100).round();

    final myCreatorProfile = ref.watch(ownCreatorProfileProvider).value;
    final myCategories = myCreatorProfile?.categories ?? const [];
    final openCampaigns = ref.watch(openCampaignsProvider).value ?? const [];
    final matching = myCategories.isEmpty
        ? const <Campaign>[]
        : openCampaigns
              .where((c) => c.categories.any(myCategories.contains))
              .toList();
    final recommended = (matching.isEmpty ? openCampaigns : matching)
        .take(5)
        .toList();

    final profileItems = <(String, bool)>[
      ('Bio', (myCreatorProfile?.bio ?? '').isNotEmpty),
      ('Niche', myCategories.isNotEmpty),
      ('Languages', (myCreatorProfile?.languages ?? const []).isNotEmpty),
      (
        'Location',
        (myCreatorProfile?.city ?? '').isNotEmpty &&
            (myCreatorProfile?.state ?? '').isNotEmpty,
      ),
      (
        'Instagram connected',
        instagramAccount?.status == InstagramConnectionStatus.connected,
      ),
    ];

    final sortedApplications = [...applications]
      ..sort(
        (a, b) =>
            (b.appliedAt ?? DateTime(0)).compareTo(a.appliedAt ?? DateTime(0)),
      );
    final recentActivity = sortedApplications.take(5).toList();

    final greetingCard = Card(
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Row(
          children: [
            ProfileAvatar(
              avatarUrl: instagramAccount?.profilePictureUrl,
              fallbackIcon: Icons.person,
              radius: AppSpacing.avatarMd / 2,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: profile.when(
                data: (value) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      creatorDisplayName(value?.displayName, instagramAccount),
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      timeBasedGreeting(),
                      style: AppTextStyles.heading2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                loading: () => const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 80, height: 12),
                    SizedBox(height: 6),
                    Skeleton(width: 120, height: 16),
                  ],
                ),
                error: (error, stackTrace) => Text(
                  'Could not load your profile',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
            timeBasedGreetingIcon(color: AppColors.primary),
          ],
        ),
      ),
    );

    final statsCard = Card(
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your activity', style: AppTextStyles.titleSmall),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CountUpStat(
                  label: 'Applications sent',
                  value: sentCount,
                  color: AppColors.textPrimary,
                ),
                CountUpStat(
                  label: 'Accepted',
                  value: acceptedCount,
                  color: AppColors.success,
                ),
                CountUpStat(
                  label: 'Response rate',
                  value: responseRate,
                  suffix: '%',
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final recommendedCard = recommended.isEmpty
        ? null
        : Card(
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            shape: _cardShape,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.card,
                AppSpacing.card,
                AppSpacing.card,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Recommended for you',
                        style: AppTextStyles.titleSmall,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.creatorCampaigns),
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommended.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) =>
                          _MiniCampaignCard(campaign: recommended[index]),
                    ),
                  ),
                ],
              ),
            ),
          );

    final profileCard = ProfileCompletenessCard(
      userId: profile.value?.id ?? '',
      items: profileItems,
      cardShape: _cardShape,
      onTap: () => context.go(AppRoutes.creatorProfile),
    );

    final activityCard = recentActivity.isEmpty
        ? null
        : Card(
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            shape: _cardShape,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent activity', style: AppTextStyles.titleSmall),
                  const SizedBox(height: 12),
                  for (var i = 0; i < recentActivity.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _ActivityRow(application: recentActivity[i]),
                  ],
                ],
              ),
            ),
          );

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Collabsy',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help & Support',
            onPressed: () => context.push(AppRoutes.support),
          ),
          const NotificationBell(),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          children: [
            StaggeredFadeIn(child: greetingCard),
            const SizedBox(height: AppSpacing.xl),
            StaggeredFadeIn(
              delay: const Duration(milliseconds: 120),
              child: statsCard,
            ),
            if (recommendedCard != null) ...[
              const SizedBox(height: AppSpacing.xl),
              StaggeredFadeIn(
                delay: const Duration(milliseconds: 240),
                child: recommendedCard,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            StaggeredFadeIn(
              delay: const Duration(milliseconds: 360),
              child: profileCard,
            ),
            if (activityCard != null) ...[
              const SizedBox(height: AppSpacing.xl),
              StaggeredFadeIn(
                delay: const Duration(milliseconds: 480),
                child: activityCard,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            StaggeredFadeIn(
              delay: const Duration(milliseconds: 600),
              child: const ContactLinksCard(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.application});

  final CampaignApplication application;

  (IconData, Color, String) get _visual => switch (application.status) {
    ApplicationStatus.accepted => (
      Icons.check_circle,
      AppColors.success,
      'Accepted into',
    ),
    ApplicationStatus.completed => (
      Icons.emoji_events,
      AppColors.success,
      'Completed',
    ),
    ApplicationStatus.rejected => (
      Icons.cancel,
      AppColors.error,
      'Not selected for',
    ),
    ApplicationStatus.withdrawn => (
      Icons.undo,
      AppColors.textHint,
      'Withdrew from',
    ),
    ApplicationStatus.pending => (
      Icons.hourglass_top,
      AppColors.warning,
      'Applied to',
    ),
  };

  String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color, verb) = _visual;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
              children: [
                TextSpan(text: '$verb '),
                TextSpan(
                  text: application.campaignTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        Text(
          _timeAgo(application.appliedAt),
          style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _MiniCampaignCard extends StatelessWidget {
  const _MiniCampaignCard({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              context.push(AppRoutes.creatorCampaignDetailPath(campaign.id)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.brandName,
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  campaign.title,
                  style: AppTextStyles.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      campaign.compensationType == CompensationType.barter
                          ? Icons.handshake_outlined
                          : Icons.currency_rupee,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        campaign.compensationLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
