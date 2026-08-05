import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/auth_providers.dart';

/// A dead-end gate the router sends every suspended account to, no matter
/// where they were headed — sign-in itself still succeeds (see
/// `suspendUserAccount`), but this is the only thing reachable until an
/// admin reinstates them. The one way out besides signing out is Support,
/// which is a normal top-level route the redirect guard doesn't intercept.
class SuspendedScreen extends ConsumerWidget {
  const SuspendedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reason = ref.watch(currentProfileProvider).value?.suspendedReason;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.block,
                  size: 28,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              Text('Account suspended', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(
                (reason != null && reason.isNotEmpty)
                    ? reason
                    : 'Your account has been suspended for violating our '
                          'Terms of Service.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Contact support if you think this is a mistake — they can '
                'review and reactivate your account.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.push(AppRoutes.support),
                  child: const Text('Contact support'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => ref.read(authRepositoryProvider).signOut(),
                  child: const Text('Sign out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
