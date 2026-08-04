import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/skeleton.dart';
import '../theme/admin_colors.dart';

/// Placeholder row shaped like the Creators/Brands list rows (avatar +
/// name/subtitle + a few text columns + a trailing pill) — shown while
/// the real list is loading so the layout doesn't jump once data lands.
class AdminAvatarRowSkeleton extends StatelessWidget {
  const AdminAvatarRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AdminColors.border(context)),
      ),
      child: Row(
        children: [
          const Skeleton(
            width: 44,
            height: 44,
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Skeleton(width: 140, height: 14),
                SizedBox(height: 6),
                Skeleton(width: 180, height: 12),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(child: Skeleton(height: 12)),
          const SizedBox(width: AppSpacing.md),
          const Expanded(child: Skeleton(height: 12)),
          const SizedBox(width: AppSpacing.md),
          const Expanded(flex: 2, child: Skeleton(height: 12)),
          const SizedBox(width: AppSpacing.md),
          const Skeleton(
            width: 70,
            height: 22,
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
        ],
      ),
    );
  }
}

/// Placeholder row shaped like the Audit Logs list rows (small square
/// icon + two text lines + a trailing timestamp, no avatar/pill).
class AdminIconRowSkeleton extends StatelessWidget {
  const AdminIconRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AdminColors.border(context)),
      ),
      child: Row(
        children: [
          const Skeleton(
            width: 36,
            height: 36,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Skeleton(width: 200, height: 14),
                SizedBox(height: 6),
                Skeleton(width: 140, height: 12),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Skeleton(width: 60, height: 12),
        ],
      ),
    );
  }
}

/// Placeholder row shaped like the Outreach Leads list rows (no
/// avatar/icon — two text lines + a small trailing pill).
class AdminPlainRowSkeleton extends StatelessWidget {
  const AdminPlainRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AdminColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Skeleton(width: 160, height: 14),
                SizedBox(height: 6),
                Skeleton(width: 200, height: 12),
              ],
            ),
          ),
          const Expanded(child: Skeleton(height: 12)),
          const SizedBox(width: AppSpacing.md),
          const Skeleton(
            width: 80,
            height: 20,
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
        ],
      ),
    );
  }
}

/// Repeats a skeleton row [count] times with the same spacing the real
/// list uses — the whole loading state for a list screen.
class AdminListSkeleton extends StatelessWidget {
  const AdminListSkeleton({
    super.key,
    required this.rowBuilder,
    this.count = 6,
  });

  final WidgetBuilder rowBuilder;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          rowBuilder(context),
        ],
      ],
    );
  }
}
