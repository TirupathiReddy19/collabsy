import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/brand/models/brand_profile.dart';
import '../../features/brand/providers/brand_profile_providers.dart';
import '../../features/creator/models/creator_profile.dart';
import '../../features/creator/providers/creator_profile_providers.dart';
import '../../shared/models/verification_status.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_top_bar.dart';

/// Combined landing page for the Verification Queue section — a
/// pending-count summary across every account type that needs review,
/// linking through to each type's own full queue.
class AdminVerificationQueueScreen extends ConsumerWidget {
  const AdminVerificationQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandProfiles =
        ref.watch(brandDirectoryProvider).value ?? <BrandProfile>[];
    final pendingBrands = brandProfiles
        .where((p) => p.verificationStatus == VerificationStatus.pending)
        .length;
    final creatorProfiles =
        ref.watch(creatorDirectoryProvider).value ?? <CreatorProfile>[];
    final pendingCreators = creatorProfiles
        .where((p) => p.verificationStatus == VerificationStatus.pending)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminTopBar(
          title: 'Verification Queue',
          subtitle: 'Everything waiting on your review',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.md,
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.4,
              children: [
                AdminStatCard(
                  label: 'Brands Pending Review',
                  value: '$pendingBrands',
                  icon: Icons.business_outlined,
                  iconColor: AppColors.info,
                  onTap: () => context.go('/verification/brands'),
                ),
                AdminStatCard(
                  label: 'Creators Pending Review',
                  value: '$pendingCreators',
                  icon: Icons.people_outline,
                  iconColor: AppColors.info,
                  onTap: () => context.go('/verification/creators'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
