import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/firebase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../features/campaigns/models/application_status.dart';
import '../../features/campaigns/models/campaign_status.dart';
import '../../features/campaigns/providers/campaigns_providers.dart';
import '../../shared/models/user_role.dart';
import '../providers/admin_analytics_providers.dart';
import '../widgets/admin_analytics_charts.dart';
import '../widgets/admin_top_bar.dart';
import '../theme/admin_colors.dart';

/// Firestore-derived platform analytics — signups, application outcomes,
/// campaign categories/status. Deliberately business data, not GA4/web
/// analytics (that integration was explicitly descoped earlier).
class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() =>
      _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> {
  bool _isBackfilling = false;
  bool _isSendingWelcomes = false;

  /// One-time migration, run server-side: `setRole()` never wrote
  /// `createdAt` for password/phone signups until that bug was fixed, so
  /// every account created before then has no real signup date. The
  /// client SDK can only ever read the *signed-in* user's own Auth
  /// creation time, not other users' — so this calls a Cloud Function
  /// (running with Admin SDK privileges) that reads every account's real
  /// `metadata.creationTime` from Firebase Auth and writes it in.
  Future<void> _backfillCreatedAt() async {
    setState(() => _isBackfilling = true);
    try {
      final result = await ref
          .read(firebaseFunctionsProvider)
          .httpsCallable('backfillCreatedAtFromAuth')
          .call();
      final updated = result.data['updated'] as int;

      if (!mounted) return;
      AppSnackbar.showSuccess(
        context,
        updated == 0
            ? 'Nothing to backfill.'
            : 'Backfilled $updated account${updated == 1 ? '' : 's'} with '
                  'their real signup date.',
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        e.message ?? "Couldn't backfill signup dates.",
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't backfill signup dates.");
    } finally {
      if (mounted) setState(() => _isBackfilling = false);
    }
  }

  /// One-time catch-up for every creator/brand already approved before the
  /// welcome-message automation existed — going forward, `onCreatorApproved`
  /// / `onBrandApproved` send it automatically the moment admin approves
  /// someone, from any screen. Safe to tap more than once: the Cloud
  /// Function skips anyone who's already received their welcome.
  Future<void> _sendWelcomeBackfill() async {
    setState(() => _isSendingWelcomes = true);
    try {
      final result = await ref
          .read(firebaseFunctionsProvider)
          .httpsCallable('backfillWelcomeMessages')
          .call();
      final sent = result.data['sent'] as int;

      if (!mounted) return;
      AppSnackbar.showSuccess(
        context,
        sent == 0
            ? 'Everyone already has their welcome message.'
            : 'Sent a welcome message to $sent existing account'
                  '${sent == 1 ? '' : 's'}.',
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        e.message ?? "Couldn't send welcome messages.",
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't send welcome messages.");
    } finally {
      if (mounted) setState(() => _isSendingWelcomes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final signups = ref.watch(allUserSignupsProvider);
    final campaigns = ref.watch(allCampaignsProvider);
    final applications = ref.watch(allApplicationsProvider);
    final activity = ref.watch(allDailyActivityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminTopBar(
          title: 'Platform Analytics',
          subtitle: 'Signups, applications, and campaign trends',
          actions: [
            TextButton.icon(
              onPressed: _isBackfilling ? null : _backfillCreatedAt,
              icon: _isBackfilling
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.history, size: 18),
              label: const Text('Backfill signup dates'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _isSendingWelcomes ? null : _sendWelcomeBackfill,
              icon: _isSendingWelcomes
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.celebration_outlined, size: 18),
              label: const Text('Send welcome to existing users'),
            ),
          ],
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
                Text(
                  'New signups (last 14 days)',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 8),
                AdminCard(
                  child: signups.when(
                    data: (data) => DailySignupsChart(signups: data),
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (error, _) => Text('Failed to load: $error'),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Accounts created before signup-date tracking existed '
                  'need one "Backfill signup dates" run (above) to show up '
                  'here with their real signup date.',
                  style: AppTextStyles.micro.copyWith(
                    color: AdminColors.textHint(context),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Daily active users (last 14 days)',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 8),
                AdminCard(
                  child: activity.when(
                    data: (data) {
                      final roleByUserId = <String, UserRole?>{
                        for (final signup in signups.value ?? const [])
                          signup.userId: signup.role,
                      };
                      return DailyActiveUsersChart(
                        activity: data,
                        roleByUserId: roleByUserId,
                      );
                    },
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (error, _) => Text('Failed to load: $error'),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Counts a user once per day the app confirms they '
                  "signed in — only from today onward, there's no history "
                  'before this was added.',
                  style: AppTextStyles.micro.copyWith(
                    color: AdminColors.textHint(context),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Applications by status', style: AppTextStyles.titleSmall),
                const SizedBox(height: 8),
                AdminCard(
                  child: applications.when(
                    data: (items) {
                      final counts = {
                        for (final status in ApplicationStatus.values)
                          status.label: items
                              .where((a) => a.status == status)
                              .length,
                      };
                      return AdminBarList(
                        counts: counts,
                        color: AppColors.info,
                      );
                    },
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (error, _) => Text('Failed to load: $error'),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Campaigns by status', style: AppTextStyles.titleSmall),
                const SizedBox(height: 8),
                AdminCard(
                  child: campaigns.when(
                    data: (items) {
                      final counts = {
                        for (final status in CampaignStatus.values)
                          status.label: items
                              .where((c) => c.status == status)
                              .length,
                      };
                      return AdminBarList(
                        counts: counts,
                        color: AppColors.purple,
                      );
                    },
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (error, _) => Text('Failed to load: $error'),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Top campaign categories',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 8),
                AdminCard(
                  child: campaigns.when(
                    data: (items) {
                      final counts = <String, int>{};
                      for (final campaign in items) {
                        for (final category in campaign.categories) {
                          counts[category] = (counts[category] ?? 0) + 1;
                        }
                      }
                      final sorted = counts.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));
                      final top = Map.fromEntries(sorted.take(8));
                      return top.isEmpty
                          ? Text(
                              'No categories yet.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AdminColors.textSecondary(context),
                              ),
                            )
                          : AdminBarList(counts: top, color: AppColors.primary);
                    },
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (error, _) => Text('Failed to load: $error'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
