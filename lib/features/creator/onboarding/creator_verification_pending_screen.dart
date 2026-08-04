import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/verification_status.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/creator_profile_providers.dart';

/// Shown instead of the dashboard for any Creator whose profile hasn't been
/// approved yet — new signups land here right after connecting Instagram,
/// and any pre-existing account without an explicit `verificationStatus:
/// approved` lands here too the next time they open the app (see the
/// router's redirect guard). Watches the profile live so it moves on to
/// the dashboard the instant an admin approves, with no relaunch needed.
class CreatorVerificationPendingScreen extends ConsumerWidget {
  const CreatorVerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(ownCreatorProfileStreamProvider);

    ref.listen(ownCreatorProfileStreamProvider, (previous, next) {
      if (next.value?.verificationStatus == VerificationStatus.approved) {
        context.go(AppRoutes.creatorHome);
      }
    });

    final status =
        profileAsync.value?.verificationStatus ?? VerificationStatus.pending;
    final isRejected = status == VerificationStatus.rejected;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isRejected
                        ? AppColors.errorLight
                        : AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRejected
                        ? Icons.cancel_outlined
                        : Icons.hourglass_top_outlined,
                    size: 32,
                    color: isRejected ? AppColors.error : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isRejected ? 'Profile not approved' : "You're almost there",
                  style: AppTextStyles.heading2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isRejected
                      ? "We couldn't verify your profile. Please check your "
                            'connected Instagram or reach out to support.'
                      : 'Your profile is under review. This usually takes '
                            "15–30 minutes — we'll take you straight to your "
                            'dashboard once approved.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => ref.read(authRepositoryProvider).signOut(),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
