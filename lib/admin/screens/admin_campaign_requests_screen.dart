import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../providers/admin_campaign_requests_providers.dart';
import '../theme/admin_colors.dart';
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

String _budgetLabel(String value) => switch (value) {
  'under_50k' => 'Under ₹50,000/mo',
  '50k_2l' => '₹50,000 – ₹2,00,000/mo',
  '2l_10l' => '₹2,00,000 – ₹10,00,000/mo',
  '10l_plus' => '₹10,00,000+/mo',
  _ => 'Not sure yet',
};

String _statusLabel(String status) => switch (status) {
  'contacted' => 'Contacted',
  'closed' => 'Closed',
  _ => 'New',
};

Color _statusColor(BuildContext context, String status) => switch (status) {
  'contacted' => AppColors.info,
  'closed' => AdminColors.textSecondary(context),
  _ => AppColors.success,
};

/// Managed-campaign leads submitted from the public marketing website's
/// Brands page — see `lib/website/widgets/campaign_request_form.dart`.
/// Deliberately manual status tracking (new → contacted → closed), no
/// automation — staff follow up directly with the brand.
class AdminCampaignRequestsScreen extends ConsumerWidget {
  const AdminCampaignRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(allCampaignRequestsProvider);
    final isLoading = ref
        .watch(adminCampaignRequestsControllerProvider)
        .isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminTopBar(
          title: 'Campaign Requests',
          subtitle:
              'Managed-campaign leads submitted from the public website\'s '
              'Brands page',
        ),
        Expanded(
          child: requestsAsync.when(
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
            data: (requests) {
              if (requests.isEmpty) {
                return const EmptyState(
                  icon: Icons.request_quote_outlined,
                  title: 'No campaign requests yet',
                  subtitle:
                      'Leads submitted from the website\'s Brands page '
                      'will show up here.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.md,
                ),
                itemCount: requests.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => StaggeredFadeIn(
                  key: ValueKey(requests[index].id),
                  delay: Duration(milliseconds: (index * 40).clamp(0, 400)),
                  child: _RequestRow(
                    request: requests[index],
                    isLoading: isLoading,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RequestRow extends ConsumerWidget {
  const _RequestRow({required this.request, required this.isLoading});

  final CampaignRequest request;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.companyName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(
                          context,
                          request.status,
                        ).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _statusLabel(request.status),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _statusColor(context, request.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${request.contactName} · ${request.workEmail}'
                  '${request.phone == null || request.phone!.isEmpty ? '' : ' · ${request.phone}'}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AdminColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_budgetLabel(request.budgetRange)} · ${_fmt(request.createdAt)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AdminColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(request.campaignBrief, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    if (request.status != 'contacted')
                      OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => ref
                                  .read(
                                    adminCampaignRequestsControllerProvider
                                        .notifier,
                                  )
                                  .updateStatus(request.id, 'contacted'),
                        child: const Text('Mark contacted'),
                      ),
                    if (request.status != 'closed')
                      OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => ref
                                  .read(
                                    adminCampaignRequestsControllerProvider
                                        .notifier,
                                  )
                                  .updateStatus(request.id, 'closed'),
                        child: const Text('Mark closed'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
