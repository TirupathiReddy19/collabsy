import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/verified_badge.dart';
import '../providers/announcements_providers.dart';

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
  if (time == null) return '';
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? 'PM' : 'AM';
  return '${_months[time.month - 1]} ${time.day} · $hour:$minute $period';
}

/// Read-only, reverse-chronological feed of every broadcast the signed-in
/// Creator is eligible to see — reached by tapping the pinned "Collabsy
/// Team" card in the Messages tab (see [ChatListScreen]). One-way: there's
/// no reply input, since a broadcast isn't a conversation.
class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() =>
      _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(announcementsControllerProvider.notifier).markRead(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(myAnnouncementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Collabsy Team'),
            const SizedBox(width: 6),
            const VerifiedBadge(
              variant: VerifiedBadgeVariant.broadcast,
              size: 18,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: announcementsAsync.when(
          data: (announcements) {
            if (announcements.isEmpty) {
              return const Center(
                child: EmptyState(
                  icon: Icons.campaign_outlined,
                  title: 'No announcements yet',
                  subtitle: 'Updates from the Collabsy team will show up here.',
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.card),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(announcement.title, style: AppTextStyles.titleSmall),
                      const SizedBox(height: 4),
                      Text(announcement.body, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 8),
                      Text(
                        _fmt(announcement.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
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
              title: "Couldn't load announcements",
              subtitle: 'Please try again in a moment.',
            ),
          ),
        ),
      ),
    );
  }
}
