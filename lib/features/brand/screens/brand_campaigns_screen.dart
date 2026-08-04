import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../campaigns/providers/campaigns_providers.dart';
import '../../campaigns/widgets/campaign_card.dart';

class BrandCampaignsScreen extends ConsumerWidget {
  const BrandCampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(brandCampaignsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Campaigns')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createCampaign),
        icon: const Icon(Icons.add),
        label: const Text('New campaign'),
      ),
      body: SafeArea(
        child: campaigns.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: EmptyState(
                  icon: Icons.campaign_outlined,
                  title: 'No campaigns yet',
                  subtitle: 'Tap "New campaign" to create your first one.',
                ),
              );
            }
            final sorted = [...items]
              ..sort(
                (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
                  a.createdAt ?? DateTime(0),
                ),
              );
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              itemCount: sorted.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final campaign = sorted[index];
                return CampaignCard(
                  campaign: campaign,
                  showStatus: true,
                  onTap: () => context.push(
                    AppRoutes.brandCampaignDetailPath(campaign.id),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, stackTrace) => const Center(
            child: EmptyState(
              icon: Icons.error_outline,
              title: "Couldn't load your campaigns",
              subtitle: 'Please try again in a moment.',
            ),
          ),
        ),
      ),
    );
  }
}
