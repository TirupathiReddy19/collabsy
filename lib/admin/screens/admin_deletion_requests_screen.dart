import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../providers/admin_deletion_requests_providers.dart';
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

/// Requests submitted from the public web page linked from the Play
/// Console Data Safety form — see `web-legal/delete-account/index.html`.
/// Deliberately manual: staff verify the identifier really belongs to the
/// account before running the same `deleteAccount` flow the in-app button
/// uses, rather than deleting anything automatically off an unauthenticated
/// form submission.
class AdminDeletionRequestsScreen extends ConsumerWidget {
  const AdminDeletionRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(allDeletionRequestsProvider);
    final isLoading = ref
        .watch(adminDeletionRequestsControllerProvider)
        .isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminTopBar(
          title: 'Account Deletion Requests',
          subtitle:
              'Submitted from the public web form — verify the account '
              'before deleting it',
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
                  icon: Icons.mark_email_read_outlined,
                  title: 'No deletion requests',
                  subtitle:
                      'Requests submitted from the public web form will '
                      'show up here.',
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

  final DeletionRequest request;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = request.status == 'pending';

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
                Text(
                  request.identifier,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if ((request.reason ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    request.reason!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AdminColors.textSecondary(context),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _fmt(request.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AdminColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (isPending)
            OutlinedButton(
              onPressed: isLoading
                  ? null
                  : () => ref
                        .read(adminDeletionRequestsControllerProvider.notifier)
                        .markProcessed(request.id),
              child: const Text('Mark processed'),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AdminColors.border(context)),
              ),
              child: Text(
                'Processed',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AdminColors.textSecondary(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
