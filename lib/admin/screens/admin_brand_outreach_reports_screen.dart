import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../providers/admin_brand_outreach_reports_providers.dart';
import '../theme/admin_colors.dart';
import '../widgets/admin_row_skeleton.dart';
import '../widgets/admin_top_bar.dart';

/// All-time, per-intern view across both brand-outreach funnels: the
/// personally-generated `BrandLead` link funnel and the admin-pushed
/// `BrandProspect` outreach pool — see
/// `admin_brand_outreach_reports_providers.dart` for how the two are
/// combined. Deliberately cumulative, not date-scoped (unlike Intern Shift
/// Report), since this is meant to answer "how is each intern doing
/// overall", not "today". Admin-only: `brandProspects` reads here are
/// cross-intern, which Firestore rules only allow the real admin account
/// to do (see `admin_router.dart`'s super-admin-only gate for this route).
class AdminBrandOutreachReportsScreen extends ConsumerWidget {
  const AdminBrandOutreachReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(brandOutreachInternSummariesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminTopBar(
          title: 'Brand Outreach Reports',
          subtitle:
              'Every brand-outreach intern\'s link funnel and prospect '
              'outreach, all time',
        ),
        Expanded(
          child: summariesAsync.when(
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
            data: (summaries) {
              if (summaries.isEmpty) {
                return const EmptyState(
                  icon: Icons.groups_outlined,
                  title: 'No brand-outreach interns yet',
                  subtitle:
                      'Grant an active staff account the Brand Outreach '
                      'Leads permission to see them here.',
                );
              }

              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.md,
                ),
                children: [
                  _TotalsRow(summaries: summaries),
                  const SizedBox(height: AppSpacing.md),
                  for (final (index, summary) in summaries.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: StaggeredFadeIn(
                        key: ValueKey(summary.internId),
                        delay: Duration(milliseconds: (index * 40).clamp(0, 400)),
                        child: _InternReportCard(summary: summary),
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

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.summaries});

  final List<BrandOutreachInternSummary> summaries;

  @override
  Widget build(BuildContext context) {
    int sum(int Function(BrandOutreachInternSummary) pick) =>
        summaries.fold(0, (total, s) => total + pick(s));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AdminColors.border(context)),
      ),
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.sm,
        children: [
          _ReportStat(label: 'Interns', value: summaries.length),
          _ReportStat(label: 'Links sent', value: sum((s) => s.linksSent)),
          _ReportStat(label: 'Signed up', value: sum((s) => s.signedUp)),
          _ReportStat(label: 'Onboarded', value: sum((s) => s.onboarded)),
          _ReportStat(
            label: 'Prospects assigned',
            value: sum((s) => s.prospectsAssigned),
          ),
          _ReportStat(
            label: 'Prospects contacted',
            value: sum((s) => s.prospectsContacted),
          ),
        ],
      ),
    );
  }
}

class _InternReportCard extends StatelessWidget {
  const _InternReportCard({required this.summary});

  final BrandOutreachInternSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AdminColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.internEmail,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Text(
            'Outreach links',
            style: AppTextStyles.labelSmall.copyWith(
              color: AdminColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: 6,
            children: [
              _ReportStat(label: 'Sent', value: summary.linksSent),
              _ReportStat(label: 'Clicked', value: summary.linksClicked),
              _ReportStat(label: 'Signed up', value: summary.signedUp),
              _ReportStat(label: 'Onboarded', value: summary.onboarded),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Divider(height: 1, color: AdminColors.border(context)),
          const SizedBox(height: AppSpacing.sm + 2),
          Text(
            'Prospect pool',
            style: AppTextStyles.labelSmall.copyWith(
              color: AdminColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: 6,
            children: [
              _ReportStat(label: 'Assigned', value: summary.prospectsAssigned),
              _ReportStat(
                label: 'Contacted',
                value: summary.prospectsContacted,
              ),
              _ReportStat(
                label: 'Bulk emailed',
                value: summary.prospectsBulkEmailed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportStat extends StatelessWidget {
  const _ReportStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AdminColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}
