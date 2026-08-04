import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../../shared/models/verification_status.dart';
import '../../auth/providers/auth_providers.dart';
import '../../brand/providers/brand_profile_providers.dart';
import '../models/campaign.dart';
import '../models/campaign_status.dart';
import '../models/compensation_type.dart';

/// Summary card for a campaign — used in both the Brand's own-campaigns
/// list and the Creator's browse list. Feed-style layout: the posting
/// brand's identity up top (matches how a creator would recognize who's
/// hiring), then the campaign headline/description, then icon chips for
/// the details that actually vary per campaign.
class CampaignCard extends ConsumerWidget {
  const CampaignCard({
    super.key,
    required this.campaign,
    required this.onTap,
    this.showStatus = false,
  });

  final Campaign campaign;
  final VoidCallback onTap;

  /// Shown for the brand's own list (their campaigns can be draft/paused/
  /// closed); not shown on the creator's browse list, which only ever
  /// contains active campaigns.
  final bool showStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appProfile = ref
        .watch(appUserProfileByIdProvider(campaign.brandId))
        .value;
    final brandProfile = ref
        .watch(brandProfileByIdProvider(campaign.brandId))
        .value;

    return Card(
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.card),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileAvatar(
                    avatarUrl: appProfile?.avatarUrl,
                    fallbackIcon: Icons.storefront,
                    radius: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                campaign.brandName,
                                style: AppTextStyles.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (brandProfile?.verificationStatus ==
                                VerificationStatus.approved) ...[
                              const SizedBox(width: 4),
                              const VerifiedBadge(
                                variant: VerifiedBadgeVariant.brand,
                                size: 14,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          [
                            brandProfile?.designation,
                            campaign.postedAgoLabel,
                          ].where((s) => (s ?? '').isNotEmpty).join(' · '),
                          style: AppTextStyles.micro.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (showStatus) ...[
                    _StatusBadge(status: campaign.status),
                    const SizedBox(width: 4),
                  ],
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                campaign.title,
                style: AppTextStyles.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (campaign.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  campaign.description,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  _InfoChip(
                    icon: campaign.compensationType == CompensationType.barter
                        ? Icons.handshake_outlined
                        : Icons.currency_rupee,
                    label: campaign.compensationLabel,
                  ),
                  _InfoChip(
                    icon: Icons.category_outlined,
                    label: campaign.categoriesLabel,
                  ),
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    label: campaign.targetLocationsLabel,
                  ),
                  _InfoChip(
                    icon: Icons.event_outlined,
                    label: campaign.timelineLabel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CampaignStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      CampaignStatus.active => AppColors.success,
      CampaignStatus.underReview => AppColors.info,
      CampaignStatus.paused => AppColors.warning,
      CampaignStatus.rejected => AppColors.error,
      CampaignStatus.closed => AppColors.textHint,
      CampaignStatus.draft => AppColors.secondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.micro.copyWith(color: color),
      ),
    );
  }
}
