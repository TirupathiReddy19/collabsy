import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/campaign_categories.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../campaigns/models/application_status.dart';
import '../../campaigns/models/campaign_application.dart';
import '../../campaigns/models/deliverable_type.dart';
import '../../campaigns/providers/campaigns_providers.dart';
import '../../campaigns/widgets/campaign_card.dart';

/// Creator's Campaigns tab — browse open campaigns with category/deliverable
/// filters, or check the status of campaigns already applied to.
class CreatorCampaignsScreen extends StatefulWidget {
  const CreatorCampaignsScreen({super.key});

  @override
  State<CreatorCampaignsScreen> createState() => _CreatorCampaignsScreenState();
}

class _CreatorCampaignsScreenState extends State<CreatorCampaignsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Browse'),
            Tab(text: 'Applied'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: const [_BrowseTab(), _AppliedTab()],
        ),
      ),
    );
  }
}

class _BrowseTab extends ConsumerWidget {
  const _BrowseTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(openCampaignsProvider);
    final category = ref.watch(campaignCategoryFilterProvider);
    final deliverableType = ref.watch(campaignDeliverableTypeFilterProvider);

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              _FilterChip(
                label: category ?? 'Category',
                selected: category != null,
                onTap: () => _pickCategory(context, ref),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: deliverableType?.label ?? 'Deliverable',
                selected: deliverableType != null,
                onTap: () => _pickDeliverableType(context, ref),
              ),
            ],
          ),
        ),
        Expanded(
          child: campaigns.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: EmptyState(
                    icon: Icons.work_outline,
                    title: 'No open campaigns right now',
                    subtitle: 'Check back soon, or try a different filter.',
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final campaign = items[index];
                  return CampaignCard(
                    campaign: campaign,
                    onTap: () => context.push(
                      AppRoutes.creatorCampaignDetailPath(campaign.id),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, stackTrace) => const Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: "Couldn't load campaigns",
                subtitle: 'Please try again in a moment.',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickCategory(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => _FilterSheet(
        title: 'Category',
        options: campaignCategories,
        onClear: () => Navigator.of(context).pop(),
      ),
    );
    ref.read(campaignCategoryFilterProvider.notifier).set(result);
  }

  Future<void> _pickDeliverableType(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<DeliverableType?>(
      context: context,
      builder: (context) => _DeliverableFilterSheet(),
    );
    ref.read(campaignDeliverableTypeFilterProvider.notifier).set(result);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: selected ? AppColors.primaryLight : AppColors.surface,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: selected ? AppColors.primaryDark : AppColors.textSecondary,
      ),
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      avatar: Icon(
        Icons.arrow_drop_down,
        color: selected ? AppColors.primaryDark : AppColors.textSecondary,
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.title,
    required this.options,
    required this.onClear,
  });

  final String title;
  final List<String> options;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('All ${title.toLowerCase()}s'),
            onTap: () => Navigator.of(context).pop(),
          ),
          for (final option in options)
            ListTile(
              title: Text(option),
              onTap: () => Navigator.of(context).pop(option),
            ),
        ],
      ),
    );
  }
}

class _DeliverableFilterSheet extends StatelessWidget {
  const _DeliverableFilterSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('All deliverables'),
            onTap: () => Navigator.of(context).pop(),
          ),
          for (final type in DeliverableType.values)
            ListTile(
              title: Text(type.label),
              onTap: () => Navigator.of(context).pop(type),
            ),
        ],
      ),
    );
  }
}

class _AppliedTab extends ConsumerWidget {
  const _AppliedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(creatorApplicationsProvider);

    return applications.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: EmptyState(
              icon: Icons.assignment_outlined,
              title: "You haven't applied to any campaigns yet",
              subtitle: 'Campaigns you apply to will show up here.',
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          itemCount: items.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final application = items[index];
            return Card(
              elevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.06),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(application.campaignTitle),
                    subtitle: Text(application.status.label),
                    trailing: _ApplicationStatusIcon(
                      status: application.status,
                    ),
                    onTap: () => context.push(
                      AppRoutes.creatorCampaignDetailPath(
                        application.campaignId,
                      ),
                    ),
                  ),
                  if (application.status == ApplicationStatus.pending)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _withdraw(context, ref, application),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('Withdraw'),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stackTrace) => const Center(
        child: EmptyState(
          icon: Icons.error_outline,
          title: "Couldn't load your applications",
        ),
      ),
    );
  }

  Future<void> _withdraw(
    BuildContext context,
    WidgetRef ref,
    CampaignApplication application,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw application?'),
        content: Text(
          'This withdraws your application to '
          '"${application.campaignTitle}". The brand will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref
        .read(campaignControllerProvider.notifier)
        .withdrawApplication(
          applicationId: application.id,
          campaignId: application.campaignId,
          campaignTitle: application.campaignTitle,
          brandId: application.brandId,
          creatorName: application.creatorName,
        );
    if (!context.mounted) return;
    if (ref.read(campaignControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't withdraw your application.");
      return;
    }
    AppSnackbar.showSuccess(context, 'Application withdrawn.');
  }
}

class _ApplicationStatusIcon extends StatelessWidget {
  const _ApplicationStatusIcon({required this.status});

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      ApplicationStatus.accepted => (Icons.check_circle, AppColors.success),
      ApplicationStatus.rejected => (Icons.cancel, AppColors.error),
      ApplicationStatus.withdrawn => (Icons.undo, AppColors.textHint),
      ApplicationStatus.completed => (Icons.task_alt, AppColors.secondary),
      ApplicationStatus.pending => (Icons.hourglass_top, AppColors.warning),
    };
    return Icon(icon, color: color);
  }
}
