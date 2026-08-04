import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/url_utils.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/linkedin_icon.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/models/verification_status.dart';
import '../../auth/providers/auth_providers.dart';
import '../../blocking/providers/blocking_providers.dart';
import '../../blocking/widgets/report_user_sheet.dart';
import '../../brand/providers/brand_profile_providers.dart';
import '../../chat/providers/chat_providers.dart';

/// Read-only, Creator-facing view of a brand's profile — reached by
/// tapping the brand header on a campaign's detail screen.
class BrandPublicProfileScreen extends ConsumerWidget {
  const BrandPublicProfileScreen({super.key, required this.brandId});

  final String brandId;

  Future<void> _launch(String? url) async {
    final uri = normalizedExternalUri(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _message(
    BuildContext context,
    WidgetRef ref,
    String brandName,
  ) async {
    final chatId = await ref
        .read(chatControllerProvider.notifier)
        .startChatAsCreator(brandId: brandId, brandName: brandName);
    if (!context.mounted) return;
    if (ref.read(chatControllerProvider).hasError || chatId == null) {
      AppSnackbar.showError(
        context,
        "Couldn't start the chat. Please try again.",
      );
      return;
    }
    context.push(AppRoutes.chatDetailPath(chatId));
  }

  Future<void> _block(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block this user?'),
        content: const Text(
          "They won't be able to message you, and you won't be able to "
          'message them, until you unblock them from Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await ref
        .read(blockingControllerProvider.notifier)
        .block(blockedId: brandId, blockedRole: UserRole.brand);
    if (!context.mounted) return;
    if (ref.read(blockingControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't block this user.");
      return;
    }
    AppSnackbar.showSuccess(context, 'User blocked.');
  }

  Future<void> _unblock(BuildContext context, WidgetRef ref) async {
    await ref.read(blockingControllerProvider.notifier).unblock(brandId);
    if (!context.mounted) return;
    if (ref.read(blockingControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't unblock this user.");
      return;
    }
    AppSnackbar.showSuccess(context, 'User unblocked.');
  }

  Future<void> _report(BuildContext context, String brandName) async {
    await ReportUserSheet.show(
      context,
      reportedId: brandId,
      reportedRole: UserRole.brand,
      reportedName: brandName,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandProfileAsync = ref.watch(brandProfileByIdProvider(brandId));
    final appProfileAsync = ref.watch(appUserProfileByIdProvider(brandId));
    final isLoading = ref.watch(chatControllerProvider).isLoading;
    final iBlockedThem =
        ref
            .watch(myBlockedUsersProvider)
            .value
            ?.any((block) => block.blockedId == brandId) ??
        false;
    final isBlocked =
        ref.watch(isBlockedEitherWayProvider(brandId)).value ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'block':
                  _block(context, ref);
                case 'unblock':
                  _unblock(context, ref);
                case 'report':
                  final name =
                      brandProfileAsync.value?.companyName ??
                      appProfileAsync.value?.displayName ??
                      'this user';
                  _report(context, name);
              }
            },
            itemBuilder: (context) => [
              if (iBlockedThem)
                const PopupMenuItem(value: 'unblock', child: Text('Unblock'))
              else
                const PopupMenuItem(value: 'block', child: Text('Block')),
              const PopupMenuItem(value: 'report', child: Text('Report')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: brandProfileAsync.when(
          data: (brandProfile) {
            final appProfile = appProfileAsync.value;
            final brandName =
                brandProfile?.companyName ?? appProfile?.displayName ?? 'Brand';

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              children: [
                ProfileAvatar(
                  avatarUrl: appProfile?.avatarUrl,
                  fallbackIcon: Icons.storefront,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        brandName,
                        style: AppTextStyles.heading1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (brandProfile?.verificationStatus ==
                        VerificationStatus.approved) ...[
                      const SizedBox(width: 6),
                      const VerifiedBadge(
                        variant: VerifiedBadgeVariant.brand,
                        size: 22,
                      ),
                    ],
                  ],
                ),
                if ((brandProfile?.designation ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    brandProfile!.designation!,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
                if (brandProfile?.city != null ||
                    brandProfile?.state != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      brandProfile?.city,
                      brandProfile?.state,
                    ].whereType<String>().join(', '),
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
                if ((brandProfile?.bio ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(brandProfile!.bio!, style: AppTextStyles.bodyLarge),
                ],
                if (brandProfile?.categories.isNotEmpty ?? false) ...[
                  const SizedBox(height: 24),
                  Text('Industries', style: AppTextStyles.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: brandProfile!.categories
                        .map((category) => Chip(label: Text(category)))
                        .toList(),
                  ),
                ],
                if ((brandProfile?.website ?? '').isNotEmpty ||
                    (brandProfile?.linkedinUrl ?? '').isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Links', style: AppTextStyles.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if ((brandProfile?.website ?? '').isNotEmpty)
                        IconButton(
                          onPressed: () => _launch(brandProfile!.website),
                          icon: const Icon(Icons.public),
                        ),
                      if ((brandProfile?.linkedinUrl ?? '').isNotEmpty)
                        IconButton(
                          onPressed: () => _launch(brandProfile!.linkedinUrl),
                          icon: const LinkedInIcon(size: 28, fontSize: 14),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
                if (isBlocked)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        iBlockedThem
                            ? "You've blocked $brandName."
                            : '$brandName has blocked you.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (iBlockedThem) ...[
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () => _unblock(context, ref),
                          child: const Text('Unblock to send messages'),
                        ),
                      ],
                    ],
                  )
                else
                  PrimaryButton(
                    text: 'Message',
                    icon: Icons.chat_bubble_outline,
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () => _message(context, ref, brandName),
                  ),
              ],
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, stackTrace) =>
              const Center(child: Text("Couldn't load this brand.")),
        ),
      ),
    );
  }
}
