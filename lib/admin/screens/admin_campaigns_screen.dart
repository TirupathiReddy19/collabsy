import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../features/campaigns/models/campaign.dart';
import '../../features/campaigns/models/campaign_status.dart';
import '../../features/campaigns/providers/campaigns_providers.dart';
import '../widgets/admin_top_bar.dart';
import '../theme/admin_colors.dart';

class AdminCampaignsScreen extends ConsumerStatefulWidget {
  const AdminCampaignsScreen({super.key}) : lockedStatus = null;

  /// Used by the sidebar's dedicated "Under Review" page — fixes the list
  /// to one status and hides the filter chips entirely, since there's
  /// nothing left to choose.
  const AdminCampaignsScreen.locked({super.key, required CampaignStatus status})
    : lockedStatus = status;

  final CampaignStatus? lockedStatus;

  @override
  ConsumerState<AdminCampaignsScreen> createState() =>
      _AdminCampaignsScreenState();
}

class _AdminCampaignsScreenState extends ConsumerState<AdminCampaignsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  CampaignStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    // Set here, not as a field initializer — `widget` isn't attached yet
    // at field-initialization time (it's assigned by the framework right
    // before initState runs), so reading it inline would hit an
    // uninitialized/null `widget`.
    _statusFilter = widget.lockedStatus;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campaigns = ref.watch(allCampaignsProvider);
    final locked = widget.lockedStatus != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminTopBar(
          title: locked
              ? '${widget.lockedStatus!.label} Campaigns'
              : 'All Campaigns',
          subtitle: locked
              ? 'Campaigns waiting on your decision'
              : 'Every campaign across every brand',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: const InputDecoration(
              hintText: 'Search by title or brand',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        if (!locked) ...[
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
                for (final status in CampaignStatus.values) ...[
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
        ],
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: campaigns.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, _) => Center(child: Text('Failed to load: $error')),
            data: (allCampaigns) {
              final filtered = allCampaigns.where((campaign) {
                if (_statusFilter != null && campaign.status != _statusFilter) {
                  return false;
                }
                if (_query.isEmpty) return true;
                final q = _query.toLowerCase();
                return campaign.title.toLowerCase().contains(q) ||
                    campaign.brandName.toLowerCase().contains(q);
              }).toList();

              if (filtered.isEmpty) {
                return const EmptyState(
                  icon: Icons.campaign_outlined,
                  title: 'No campaigns found',
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
                    _CampaignRow(campaign: filtered[index]),
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

class _CampaignRow extends StatelessWidget {
  const _CampaignRow({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminColors.surface(context),
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        onTap: () => context.push('/campaigns/${campaign.id}'),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.card),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: AdminColors.border(context)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      campaign.brandName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AdminColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _StatusBadge(status: campaign.status)),
              Expanded(
                flex: 2,
                child: Text(
                  campaign.categoriesLabel,
                  style: AppTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  campaign.compensationLabel,
                  style: AppTextStyles.bodySmall,
                ),
              ),
              Expanded(
                child: Text(
                  campaign.postedAgoLabel,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CampaignStatus status;

  Color _color(BuildContext context) => switch (status) {
    CampaignStatus.active => AppColors.success,
    CampaignStatus.underReview => AppColors.info,
    CampaignStatus.paused => Colors.orange,
    CampaignStatus.rejected => AppColors.error,
    CampaignStatus.closed => AdminColors.textHint(context),
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
