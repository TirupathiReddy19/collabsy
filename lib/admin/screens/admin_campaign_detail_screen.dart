import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../features/campaigns/models/campaign.dart';
import '../../features/campaigns/models/campaign_status.dart';
import '../../features/campaigns/models/compensation_type.dart';
import '../../features/campaigns/providers/campaigns_providers.dart';
import '../../features/notifications/models/notification_type.dart';
import '../../features/notifications/providers/notifications_providers.dart';
import '../models/audit_log.dart';
import '../providers/admin_audit_log_providers.dart';
import '../providers/admin_auth_providers.dart';
import '../widgets/admin_detail_row.dart';
import '../widgets/admin_top_bar.dart';
import '../theme/admin_colors.dart';

class AdminCampaignDetailScreen extends ConsumerWidget {
  const AdminCampaignDetailScreen({super.key, required this.campaignId});

  final String campaignId;

  Future<void> _decide(
    BuildContext context,
    WidgetRef ref,
    Campaign campaign,
    CampaignStatus status,
  ) async {
    await ref
        .read(campaignControllerProvider.notifier)
        .updateCampaignStatus(campaignId: campaign.id, status: status);
    if (!context.mounted) return;
    if (ref.read(campaignControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't update the campaign.");
      return;
    }
    await ref
        .read(notificationsRepositoryProvider)
        .create(
          userId: campaign.brandId,
          type: status == CampaignStatus.active
              ? NotificationType.campaignApproved
              : NotificationType.campaignRejected,
          title: status == CampaignStatus.active
              ? 'Campaign approved'
              : 'Campaign not approved',
          body: status == CampaignStatus.active
              ? '${campaign.title} is now live.'
              : '${campaign.title} was not approved.',
          referenceType: 'campaign',
          referenceId: campaign.id,
        );
    await ref
        .read(adminAuditLogRepositoryProvider)
        .log(
          actorEmail: ref.read(currentAdminEmailProvider) ?? adminEmail,
          action: status == CampaignStatus.active
              ? AuditLogAction.campaignApproved
              : AuditLogAction.campaignRejected,
          targetId: campaign.id,
          targetName: campaign.title,
        );
    // `campaignByIdProvider` is a one-shot Future, not a live stream —
    // same staleness issue as the Brand detail screen's verification
    // decision: without this the Approve/Reject buttons and status badge
    // would keep showing the pre-decision state until this screen happens
    // to get disposed and refetched.
    ref.invalidate(campaignByIdProvider(campaign.id));
    if (!context.mounted) return;
    AppSnackbar.showSuccess(
      context,
      status == CampaignStatus.active
          ? 'Campaign approved.'
          : 'Campaign rejected.',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignAsync = ref.watch(campaignByIdProvider(campaignId));
    final isLoading = ref.watch(campaignControllerProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminTopBar(
          title: 'Campaign Details',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/campaigns'),
          ),
        ),
        Expanded(
          child: campaignAsync.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, _) => Center(child: Text('Failed to load: $error')),
            data: (campaign) {
              if (campaign == null) {
                return const Center(child: Text('Campaign not found.'));
              }

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
                              child: Text(
                                campaign.title,
                                style: AppTextStyles.heading2,
                              ),
                            ),
                            _StatusBadge(status: campaign.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () =>
                              context.push('/brands/${campaign.brandId}'),
                          child: Text(
                            campaign.brandName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (campaign.status == CampaignStatus.underReview) ...[
                    const SizedBox(height: 20),
                    StaggeredFadeIn(
                      delay: const Duration(milliseconds: 60),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () => _decide(
                                      context,
                                      ref,
                                      campaign,
                                      CampaignStatus.rejected,
                                    ),
                              icon: const Icon(Icons.close),
                              label: const Text('Reject'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () => _decide(
                                      context,
                                      ref,
                                      campaign,
                                      CampaignStatus.active,
                                    ),
                              icon: const Icon(Icons.check),
                              label: const Text('Approve'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  StaggeredFadeIn(
                    delay: const Duration(milliseconds: 120),
                    child: Text(
                      campaign.description,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  StaggeredFadeIn(
                    delay: const Duration(milliseconds: 180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Details', style: AppTextStyles.titleSmall),
                        const SizedBox(height: 8),
                        _Card(
                          children: [
                            AdminDetailRow(
                              icon: Icons.category_outlined,
                              label: 'Niche',
                              value: campaign.categoriesLabel,
                            ),
                            if ((campaign.goal ?? '').isNotEmpty)
                              AdminDetailRow(
                                icon: Icons.flag_outlined,
                                label: 'Goal',
                                value: campaign.goal!,
                              ),
                            AdminDetailRow(
                              icon:
                                  campaign.compensationType ==
                                      CompensationType.barter
                                  ? Icons.handshake_outlined
                                  : Icons.currency_rupee,
                              label: 'Compensation',
                              value:
                                  campaign.compensationType ==
                                      CompensationType.barter
                                  ? (campaign.barterDescription ?? 'Barter')
                                  : campaign.compensationLabel,
                            ),
                            AdminDetailRow(
                              icon: Icons.people_outline,
                              label: 'Creators needed',
                              value: campaign.creatorsNeeded != null
                                  ? '${campaign.creatorsNeeded}'
                                  : 'Not specified',
                            ),
                            AdminDetailRow(
                              icon: Icons.location_on_outlined,
                              label: 'Open to creators from',
                              value: campaign.targetLocationsLabel,
                            ),
                            if (campaign.locationLabel.isNotEmpty)
                              AdminDetailRow(
                                icon: Icons.place_outlined,
                                label: 'Campaign location',
                                value: campaign.locationLabel,
                              ),
                            AdminDetailRow(
                              icon: Icons.event_outlined,
                              label: 'Timeline',
                              value: campaign.timelineLabel,
                              isLast: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  StaggeredFadeIn(
                    delay: const Duration(milliseconds: 240),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Activity', style: AppTextStyles.titleSmall),
                        const SizedBox(height: 8),
                        _Card(
                          children: [
                            AdminDetailRow(
                              icon: Icons.visibility_outlined,
                              label: 'Reach',
                              value: '${campaign.reach} creators',
                            ),
                            AdminDetailRow(
                              icon: Icons.touch_app_outlined,
                              label: 'Views',
                              value: '${campaign.viewCount}',
                            ),
                            AdminDetailRow(
                              icon: Icons.schedule_outlined,
                              label: 'Posted',
                              value: campaign.postedAgoLabel,
                              isLast: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CampaignStatus status;

  Color _color(BuildContext context) => switch (status) {
    CampaignStatus.active => AppColors.success,
    CampaignStatus.underReview => AppColors.info,
    CampaignStatus.paused => Colors.orange,
    CampaignStatus.rejected => AppColors.error,
    CampaignStatus.closed => AdminColors.textHint(context),
    CampaignStatus.expired => AdminColors.textHint(context),
    CampaignStatus.draft => AdminColors.textSecondary(context),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color(context).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.bodySmall.copyWith(
          color: _color(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AdminColors.border(context)),
      ),
      child: Column(children: children),
    );
  }
}
