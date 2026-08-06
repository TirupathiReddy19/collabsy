import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/staggered_fade_in.dart';
import '../../../shared/utils/creator_display_name.dart';
import '../../auth/providers/auth_providers.dart';
import '../../campaigns/models/application_status.dart';
import '../../campaigns/models/campaign.dart';
import '../../campaigns/models/campaign_application.dart';
import '../../campaigns/models/campaign_status.dart';
import '../../campaigns/models/compensation_type.dart';
import '../../campaigns/models/deliverable.dart';
import '../../campaigns/models/deliverable_status.dart';
import '../../campaigns/providers/campaigns_providers.dart';
import '../../chat/providers/chat_providers.dart';
import '../../notifications/models/notification_type.dart';
import '../../notifications/providers/notifications_providers.dart';
import '../../settings/providers/instagram_providers.dart';

/// Brand's campaign detail screen, once the campaign is live: an Overview
/// of submission progress, the accepted/pending Creators roster, and basic
/// reach/engagement Analytics. Application review (accept/reject) still
/// lives in the Creators tab rather than a separate screen, since that
/// workflow has to keep working regardless of how far along the campaign is.
class BrandCampaignDetailScreen extends ConsumerStatefulWidget {
  const BrandCampaignDetailScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  ConsumerState<BrandCampaignDetailScreen> createState() =>
      _BrandCampaignDetailScreenState();
}

class _BrandCampaignDetailScreenState
    extends ConsumerState<BrandCampaignDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    CampaignStatus status,
  ) async {
    await ref
        .read(campaignControllerProvider.notifier)
        .updateCampaignStatus(campaignId: widget.campaignId, status: status);
    if (!context.mounted) return;
    if (ref.read(campaignControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't update the campaign.");
      return;
    }
    AppSnackbar.showSuccess(context, 'Campaign updated.');
  }

  Future<void> _decideApplication(
    BuildContext context,
    WidgetRef ref,
    CampaignApplication application,
    Campaign campaign,
    ApplicationStatus status,
  ) async {
    await ref
        .read(campaignControllerProvider.notifier)
        .updateApplicationStatus(applicationId: application.id, status: status);
    if (!context.mounted) return;
    if (ref.read(campaignControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't update the application.");
      return;
    }
    AppSnackbar.showSuccess(
      context,
      status == ApplicationStatus.accepted
          ? 'Application accepted.'
          : 'Application rejected.',
    );
    if (status == ApplicationStatus.accepted) {
      // Always moves any existing Requests-status chat (from the creator
      // messaging first) into Messages, or creates one directly there —
      // regardless of whether an automated message is configured, matching
      // pre-existing behavior for campaigns created before this feature.
      await _ensureChatAndMaybeSend(
        ref: ref,
        application: application,
        campaign: campaign,
        autoMessage: campaign.acceptanceMessage,
      );
      await ref
          .read(deliverablesRepositoryProvider)
          .createForApplication(
            applicationId: application.id,
            campaignId: campaign.id,
            creatorId: application.creatorId,
            creatorName: application.creatorName,
            brandId: campaign.brandId,
          );
    } else if (status == ApplicationStatus.rejected &&
        campaign.rejectionMessage != null) {
      // Rejection touching chat at all is new behavior, so it's skipped
      // entirely for campaigns that predate this feature (no message set).
      await _ensureChatAndMaybeSend(
        ref: ref,
        application: application,
        campaign: campaign,
        autoMessage: campaign.rejectionMessage,
      );
    }
    await ref
        .read(notificationsRepositoryProvider)
        .create(
          userId: application.creatorId,
          type: status == ApplicationStatus.accepted
              ? NotificationType.applicationAccepted
              : NotificationType.applicationRejected,
          title: status == ApplicationStatus.accepted
              ? 'Application accepted'
              : 'Application update',
          body: status == ApplicationStatus.accepted
              ? "You've been accepted for ${campaign.title}"
              : "Your application for ${campaign.title} wasn't accepted this time",
          referenceType: 'campaign',
          referenceId: campaign.id,
        );
  }

  Future<void> _ensureChatAndMaybeSend({
    required WidgetRef ref,
    required CampaignApplication application,
    required Campaign campaign,
    required String? autoMessage,
  }) async {
    final chatRepository = ref.read(chatRepositoryProvider);
    final chatId = await chatRepository.ensureActiveChatAsBrand(
      creatorId: application.creatorId,
      creatorName: application.creatorName,
      brandId: campaign.brandId,
      brandName: campaign.brandName,
    );
    if (autoMessage == null) return;
    final brandUid = ref.read(authRepositoryProvider).currentUser?.uid;
    if (brandUid == null) return;
    await chatRepository.sendMessage(
      chatId: chatId,
      senderId: brandUid,
      text: autoMessage,
    );
  }

  Future<void> _messageCreator(
    BuildContext context,
    WidgetRef ref,
    CampaignApplication application,
  ) async {
    final chatId = await ref
        .read(chatControllerProvider.notifier)
        .startChatAsBrand(
          creatorId: application.creatorId,
          creatorName: application.creatorName,
        );
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

  Future<void> _approveDeliverable(
    BuildContext context,
    WidgetRef ref,
    Deliverable deliverable,
    Campaign campaign,
  ) async {
    await ref
        .read(deliverableControllerProvider.notifier)
        .approve(deliverableId: deliverable.id);
    if (!context.mounted) return;
    if (ref.read(deliverableControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't approve the deliverable.");
      return;
    }
    await ref
        .read(notificationsRepositoryProvider)
        .create(
          userId: deliverable.creatorId,
          type: NotificationType.deliverableApproved,
          title: 'Deliverable approved',
          body: 'Your deliverable for ${campaign.title} was approved!',
          referenceType: 'campaign',
          referenceId: campaign.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    final campaigns = ref.watch(brandCampaignsProvider).value ?? [];
    final matches = campaigns.where((c) => c.id == widget.campaignId);
    final campaign = matches.isEmpty ? null : matches.first;
    final isLoading = ref.watch(campaignControllerProvider).isLoading;

    if (campaign == null) {
      return const Scaffold(body: Center(child: LoadingIndicator()));
    }

    final applicationsProvider = campaignApplicationsProvider(
      widget.campaignId,
      campaign.brandId,
    );
    final applications = ref.watch(applicationsProvider);
    final deliverables = ref.watch(
      campaignDeliverablesProvider(widget.campaignId, campaign.brandId),
    );

    // Backfills a chat + deliverable doc for any application that was
    // accepted before these features existed — safe to run on every
    // emission since both ensureActiveChat and createForApplication are
    // no-ops once already done.
    ref.listen(applicationsProvider, (previous, next) {
      final items = next.value;
      if (items == null) return;
      for (final application in items) {
        if (application.status == ApplicationStatus.accepted) {
          ref
              .read(chatRepositoryProvider)
              .ensureActiveChatAsBrand(
                creatorId: application.creatorId,
                creatorName: application.creatorName,
                brandId: campaign.brandId,
                brandName: campaign.brandName,
              );
          ref
              .read(deliverablesRepositoryProvider)
              .createForApplication(
                applicationId: application.id,
                campaignId: campaign.id,
                creatorId: application.creatorId,
                creatorName: application.creatorName,
                brandId: campaign.brandId,
              );
        }
      }
    });

    final acceptedCount = applications.value == null
        ? 0
        : applications.value!
              .where((a) => a.status == ApplicationStatus.accepted)
              .length;
    final approvedCount = deliverables.value == null
        ? 0
        : deliverables.value!
              .where((d) => d.status == DeliverableStatus.approved)
              .length;
    final progress = acceptedCount == 0 ? 0.0 : approvedCount / acceptedCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(campaign.title),
        actions: [
          // Only shown once a campaign is past review — a brand can never
          // self-activate out of underReview/rejected (also enforced
          // server-side in firestore.rules), only pause/resume/close an
          // already-approved campaign.
          if (campaign.status != CampaignStatus.underReview &&
              campaign.status != CampaignStatus.rejected)
            PopupMenuButton<CampaignStatus>(
              enabled: !isLoading,
              onSelected: (status) => _changeStatus(context, ref, status),
              itemBuilder: (context) => [
                if (campaign.status == CampaignStatus.paused ||
                    campaign.status == CampaignStatus.closed)
                  const PopupMenuItem(
                    value: CampaignStatus.active,
                    child: Text('Activate'),
                  ),
                if (campaign.status == CampaignStatus.active)
                  const PopupMenuItem(
                    value: CampaignStatus.paused,
                    child: Text('Pause'),
                  ),
                if (campaign.status != CampaignStatus.closed)
                  const PopupMenuItem(
                    value: CampaignStatus.closed,
                    child: Text('Close'),
                  ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Creators'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (campaign.status == CampaignStatus.underReview ||
                campaign.status == CampaignStatus.rejected)
              _ReviewStatusBanner(status: campaign.status),
            _StatsHeader(
              campaign: campaign,
              creatorsCount: acceptedCount,
              progress: progress,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _OverviewTab(
                    campaign: campaign,
                    applications: applications,
                    deliverables: deliverables,
                    progress: progress,
                  ),
                  _CreatorsTab(
                    campaign: campaign,
                    applications: applications,
                    deliverables: deliverables,
                    isLoading: isLoading,
                    onAccept: (application) => _decideApplication(
                      context,
                      ref,
                      application,
                      campaign,
                      ApplicationStatus.accepted,
                    ),
                    onReject: (application) => _decideApplication(
                      context,
                      ref,
                      application,
                      campaign,
                      ApplicationStatus.rejected,
                    ),
                    onMessage: (application) =>
                        _messageCreator(context, ref, application),
                    onApprove: (deliverable) => _approveDeliverable(
                      context,
                      ref,
                      deliverable,
                      campaign,
                    ),
                  ),
                  _AnalyticsTab(campaign: campaign),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown in place of the usual pause/close controls while a campaign is
/// awaiting (or failed) admin review — the brand has nothing to act on
/// yet, just a status to see.
class _ReviewStatusBanner extends StatelessWidget {
  const _ReviewStatusBanner({required this.status});

  final CampaignStatus status;

  @override
  Widget build(BuildContext context) {
    final isRejected = status == CampaignStatus.rejected;
    final color = isRejected ? AppColors.error : AppColors.info;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isRejected ? Icons.cancel_outlined : Icons.hourglass_top_outlined,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRejected ? 'Not approved' : 'Under review',
                  style: AppTextStyles.labelLarge.copyWith(color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  isRejected
                      ? "This campaign wasn't approved and isn't visible to creators."
                      : 'Usually takes 15–30 minutes. '
                            "We'll let you know once it's approved and live.",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({
    required this.campaign,
    required this.creatorsCount,
    required this.progress,
  });

  final Campaign campaign;
  final int creatorsCount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'Budget',
              value: campaign.totalBudget != null
                  ? '₹${campaign.totalBudget}'
                  : campaign.compensationLabel,
            ),
          ),
          Expanded(
            child: _StatItem(
              label: 'Creators',
              value: campaign.creatorsNeeded != null
                  ? '$creatorsCount/${campaign.creatorsNeeded}'
                  : '$creatorsCount',
            ),
          ),
          Expanded(
            child: _StatItem(label: 'Reach', value: '${campaign.reach}'),
          ),
          Expanded(
            child: _StatItem(
              label: 'Progress',
              value: '${(progress * 100).round()}%',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleMedium),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _OverviewDetailRow extends StatelessWidget {
  const _OverviewDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.labelLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.campaign,
    required this.applications,
    required this.deliverables,
    required this.progress,
  });

  final Campaign campaign;
  final AsyncValue<List<CampaignApplication>> applications;
  final AsyncValue<List<Deliverable>> deliverables;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final accepted =
        applications.value
            ?.where((a) => a.status == ApplicationStatus.accepted)
            .length ??
        0;
    final submitted =
        deliverables.value
            ?.where(
              (d) =>
                  d.status == DeliverableStatus.submitted ||
                  d.status == DeliverableStatus.approved,
            )
            .length ??
        0;
    final approved =
        deliverables.value
            ?.where((d) => d.status == DeliverableStatus.approved)
            .length ??
        0;
    final pending = accepted - submitted;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        StaggeredFadeIn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(campaign.description, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 20),
              Text('Details', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.card),
                  child: Column(
                    children: [
                      _OverviewDetailRow(
                        icon: Icons.category_outlined,
                        label: 'Niche',
                        value: campaign.categoriesLabel,
                      ),
                      if ((campaign.goal ?? '').isNotEmpty)
                        _OverviewDetailRow(
                          icon: Icons.flag_outlined,
                          label: 'Goal',
                          value: campaign.goal!,
                        ),
                      _OverviewDetailRow(
                        icon:
                            campaign.compensationType == CompensationType.barter
                            ? Icons.handshake_outlined
                            : Icons.currency_rupee,
                        label: 'Compensation',
                        value:
                            campaign.compensationType == CompensationType.barter
                            ? (campaign.barterDescription ?? 'Barter')
                            : campaign.compensationLabel,
                      ),
                      _OverviewDetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'Open to creators from',
                        value: campaign.targetLocationsLabel,
                      ),
                      if (campaign.locationLabel.isNotEmpty)
                        _OverviewDetailRow(
                          icon: Icons.place_outlined,
                          label: 'Campaign location',
                          value: campaign.locationLabel,
                        ),
                      _OverviewDetailRow(
                        icon: Icons.event_outlined,
                        label: 'Timeline',
                        value: campaign.timelineLabel,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        StaggeredFadeIn(
          delay: const Duration(milliseconds: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.card),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campaign progress',
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        campaign.timelineLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Overall completion',
                            style: AppTextStyles.bodySmall,
                          ),
                          const Spacer(),
                          Text(
                            '${(progress * 100).round()}%',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: AppColors.border,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _ProgressStat(
                              label: 'Submitted',
                              value: '$submitted/$accepted',
                              color: AppColors.secondary,
                            ),
                          ),
                          Expanded(
                            child: _ProgressStat(
                              label: 'Approved',
                              value: '$approved/$accepted',
                              color: AppColors.success,
                            ),
                          ),
                          Expanded(
                            child: _ProgressStat(
                              label: 'Pending',
                              value: '$pending',
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        StaggeredFadeIn(
          delay: const Duration(milliseconds: 180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Deliverables', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.card),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.video_camera_back_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            campaign.deliverableType.label,
                            style: AppTextStyles.titleSmall,
                          ),
                        ],
                      ),
                      if (campaign.instagramStoryCount > 0 ||
                          campaign.instagramPostCount > 0) ...[
                        const SizedBox(height: 12),
                        if (campaign.instagramStoryCount > 0)
                          Text(
                            '${campaign.instagramStoryCount} Instagram Story per creator',
                            style: AppTextStyles.bodySmall,
                          ),
                        if (campaign.instagramPostCount > 0)
                          Text(
                            '${campaign.instagramPostCount} Instagram Post per creator',
                            style: AppTextStyles.bodySmall,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleSmall.copyWith(color: color)),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _CreatorsTab extends StatelessWidget {
  const _CreatorsTab({
    required this.campaign,
    required this.applications,
    required this.deliverables,
    required this.isLoading,
    required this.onAccept,
    required this.onReject,
    required this.onMessage,
    required this.onApprove,
  });

  final Campaign campaign;
  final AsyncValue<List<CampaignApplication>> applications;
  final AsyncValue<List<Deliverable>> deliverables;
  final bool isLoading;
  final ValueChanged<CampaignApplication> onAccept;
  final ValueChanged<CampaignApplication> onReject;
  final ValueChanged<CampaignApplication> onMessage;
  final ValueChanged<Deliverable> onApprove;

  @override
  Widget build(BuildContext context) {
    return applications.when(
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.people_outline,
            title: 'No applications yet',
            subtitle: 'Creators who apply will show up here.',
          );
        }
        final deliverableByApplication = {
          for (final d in deliverables.value ?? const <Deliverable>[])
            d.applicationId: d,
        };
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          itemCount: items.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final application = items[index];
            return StaggeredFadeIn(
              key: ValueKey(application.id),
              delay: Duration(milliseconds: (index * 40).clamp(0, 400)),
              child: _CreatorRow(
                campaign: campaign,
                application: application,
                deliverable: deliverableByApplication[application.id],
                isLoading: isLoading,
                onAccept: () => onAccept(application),
                onReject: () => onReject(application),
                onMessage: () => onMessage(application),
                onApprove: (deliverable) => onApprove(deliverable),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stackTrace) => const EmptyState(
        icon: Icons.error_outline,
        title: "Couldn't load applications",
      ),
    );
  }
}

class _CreatorRow extends ConsumerWidget {
  const _CreatorRow({
    required this.campaign,
    required this.application,
    required this.deliverable,
    required this.isLoading,
    required this.onAccept,
    required this.onReject,
    required this.onMessage,
    required this.onApprove,
  });

  final Campaign campaign;
  final CampaignApplication application;
  final Deliverable? deliverable;
  final bool isLoading;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onMessage;
  final ValueChanged<Deliverable> onApprove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = application.status == ApplicationStatus.pending;
    final isAccepted = application.status == ApplicationStatus.accepted;
    final deliverableStatus = deliverable?.status ?? DeliverableStatus.pending;
    // Instagram is a creator's only photo source (manual avatar upload was
    // removed for creators) — never fall back to a stale `users/{uid}.
    // avatarUrl` left over from before that change.
    final instagram = ref
        .watch(instagramAccountForUserProvider(application.creatorId))
        .value;
    final avatarUrl = instagram?.profilePictureUrl;
    // Never trust `application.creatorName`'s stored snapshot on its own —
    // see the same fix in chat_list_screen.dart/chat_conversation_screen.dart.
    final creatorName = creatorDisplayName(
      ref
          .watch(appUserProfileByIdProvider(application.creatorId))
          .value
          ?.displayName,
      instagram,
      fallback: application.creatorName,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => context.push(
                AppRoutes.creatorPublicProfilePath(application.creatorId),
              ),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  ProfileAvatar(
                    avatarUrl: avatarUrl,
                    fallbackIcon: Icons.person,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(creatorName, style: AppTextStyles.titleSmall),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _StatusChip(
                              label: isPending
                                  ? 'Pending review'
                                  : isAccepted
                                  ? deliverableStatus.label
                                  : application.status.label,
                              color: isPending
                                  ? AppColors.warning
                                  : isAccepted
                                  ? _colorFor(deliverableStatus)
                                  : AppColors.textHint,
                            ),
                            _StatusChip(
                              label: campaign.deliverableType.label,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.primary,
                    ),
                    onPressed: isLoading ? null : onMessage,
                  ),
                ],
              ),
            ),
            if (application.agreedDeliverablesSummary != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Agreed: ${application.agreedDeliverablesSummary}'
                        '${application.agreedBudget != null ? ' · ₹${application.agreedBudget}/creator' : ''}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isPending) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                    onPressed: isLoading ? null : onAccept,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: AppColors.error,
                    ),
                    onPressed: isLoading ? null : onReject,
                  ),
                ],
              ),
            ],
            if (isAccepted &&
                deliverableStatus == DeliverableStatus.submitted) ...[
              const SizedBox(height: 8),
              if (deliverable?.submissionNote != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    deliverable!.submissionNote!,
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => onApprove(deliverable!),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                  ),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _colorFor(DeliverableStatus status) => switch (status) {
    DeliverableStatus.pending => AppColors.textHint,
    DeliverableStatus.submitted => AppColors.secondary,
    DeliverableStatus.approved => AppColors.success,
  };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: AppTextStyles.micro.copyWith(color: color)),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        StaggeredFadeIn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _AnalyticsCard(
                      label: 'Reach',
                      value: '${campaign.reach}',
                      subtitle: 'Creators who viewed this campaign',
                      icon: Icons.groups_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AnalyticsCard(
                      label: 'Engagement',
                      value: '${campaign.engagement}',
                      subtitle: 'Times the details were opened',
                      icon: Icons.visibility_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'More detailed analytics (daily trends, per-post reach) '
                "aren't tracked yet.",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.heading2),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.titleSmall),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.micro.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
