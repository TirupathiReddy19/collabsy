import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/url_utils.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/linkedin_icon.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../shared/models/verification_status.dart';
import '../../features/brand/providers/brand_profile_providers.dart';
import '../../features/notifications/models/notification_type.dart';
import '../../features/notifications/providers/notifications_providers.dart';
import '../models/audit_log.dart';
import '../providers/admin_account_moderation_providers.dart';
import '../providers/admin_audit_log_providers.dart';
import '../providers/admin_auth_providers.dart';
import '../widgets/admin_detail_row.dart';
import '../widgets/admin_top_bar.dart';
import '../widgets/suspend_account_dialog.dart';
import '../theme/admin_colors.dart';

class AdminBrandDetailScreen extends ConsumerStatefulWidget {
  const AdminBrandDetailScreen({super.key, required this.brandId});

  final String brandId;

  @override
  ConsumerState<AdminBrandDetailScreen> createState() =>
      _AdminBrandDetailScreenState();
}

class _AdminBrandDetailScreenState
    extends ConsumerState<AdminBrandDetailScreen> {
  bool _isDeciding = false;

  Future<void> _launch(String? url) async {
    final uri = normalizedExternalUri(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _decide(VerificationStatus status, String brandName) async {
    setState(() => _isDeciding = true);
    try {
      await ref
          .read(brandProfileRepositoryProvider)
          .setVerificationStatus(userId: widget.brandId, status: status);
      await ref
          .read(notificationsRepositoryProvider)
          .create(
            userId: widget.brandId,
            type: status == VerificationStatus.approved
                ? NotificationType.profileVerified
                : NotificationType.profileRejected,
            title: status == VerificationStatus.approved
                ? 'Profile verified'
                : 'Profile not verified',
            body: status == VerificationStatus.approved
                ? 'Your brand profile has been verified.'
                : 'Your brand profile could not be verified.',
            referenceType: 'brand',
            referenceId: widget.brandId,
          );
      await ref
          .read(adminAuditLogRepositoryProvider)
          .log(
            actorEmail: ref.read(currentAdminEmailProvider) ?? adminEmail,
            action: status == VerificationStatus.approved
                ? AuditLogAction.brandVerified
                : AuditLogAction.brandRejected,
            targetId: widget.brandId,
            targetName: brandName,
          );
      // `brandProfileByIdProvider` is a one-shot Future, not a live stream
      // — without this, the write above succeeds but this screen keeps
      // showing its already-fetched (now stale) copy, so the badge and
      // Reject/Verify buttons stay exactly as they were until the provider
      // happens to get disposed and refetched (e.g. leaving and re-entering
      // the screen).
      ref.invalidate(brandProfileByIdProvider(widget.brandId));
      if (!mounted) return;
      AppSnackbar.showSuccess(
        context,
        status == VerificationStatus.approved
            ? '$brandName verified.'
            : '$brandName rejected.',
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't update verification status.");
    } finally {
      if (mounted) setState(() => _isDeciding = false);
    }
  }

  Future<void> _suspend(String brandName) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const SuspendAccountDialog(),
    );
    if (reason == null) return;
    if (!mounted) return;

    await ref
        .read(adminAccountModerationControllerProvider.notifier)
        .suspendAccount(
          uid: widget.brandId,
          reason: reason.isEmpty ? null : reason,
        );
    if (!mounted) return;
    if (ref.read(adminAccountModerationControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't suspend this account.");
      return;
    }
    await ref
        .read(adminAuditLogRepositoryProvider)
        .log(
          actorEmail: ref.read(currentAdminEmailProvider) ?? adminEmail,
          action: AuditLogAction.brandSuspended,
          targetId: widget.brandId,
          targetName: brandName,
        );
    ref.invalidate(appUserProfileByIdProvider(widget.brandId));
    if (!mounted) return;
    AppSnackbar.showSuccess(context, '$brandName suspended.');
  }

  Future<void> _reinstate(String brandName) async {
    await ref
        .read(adminAccountModerationControllerProvider.notifier)
        .reinstateAccount(widget.brandId);
    if (!mounted) return;
    if (ref.read(adminAccountModerationControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't reinstate this account.");
      return;
    }
    await ref
        .read(adminAuditLogRepositoryProvider)
        .log(
          actorEmail: ref.read(currentAdminEmailProvider) ?? adminEmail,
          action: AuditLogAction.brandReinstated,
          targetId: widget.brandId,
          targetName: brandName,
        );
    ref.invalidate(appUserProfileByIdProvider(widget.brandId));
    if (!mounted) return;
    AppSnackbar.showSuccess(context, '$brandName reinstated.');
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(appUserProfileByIdProvider(widget.brandId));
    final profileAsync = ref.watch(brandProfileByIdProvider(widget.brandId));
    final isSuperAdmin = ref.watch(isAdminProvider);
    final isModerating = ref
        .watch(adminAccountModerationControllerProvider)
        .isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminTopBar(
          title: 'Brand Profile',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/brands'),
          ),
        ),
        Expanded(
          child: userAsync.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, _) => Center(child: Text('Failed to load: $error')),
            data: (user) {
              if (user == null) {
                return const Center(child: Text('Brand not found.'));
              }
              final profile = profileAsync.value;
              final location = [
                profile?.city,
                profile?.state,
                profile?.country,
              ].whereType<String>().where((s) => s.isNotEmpty).join(', ');
              final name = user.displayName?.isNotEmpty == true
                  ? user.displayName!
                  : 'Unnamed user';
              final designationLine = [
                profile?.designation,
                profile?.companyName,
              ].where((s) => (s ?? '').isNotEmpty).join(' at ');
              final verificationStatus =
                  profile?.verificationStatus ?? VerificationStatus.pending;

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                children: [
                  StaggeredFadeIn(
                    child: Row(
                      children: [
                        ProfileAvatar(
                          avatarUrl: user.avatarUrl,
                          fallbackIcon: Icons.business,
                          radius: 32,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      name,
                                      style: AppTextStyles.heading2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _VerificationBadge(
                                    status: verificationStatus,
                                  ),
                                ],
                              ),
                              if (designationLine.isNotEmpty)
                                Text(
                                  designationLine,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AdminColors.textSecondary(context),
                                  ),
                                ),
                              if (location.isNotEmpty)
                                Text(
                                  location,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AdminColors.textSecondary(context),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (verificationStatus == VerificationStatus.pending) ...[
                    const SizedBox(height: 20),
                    StaggeredFadeIn(
                      delay: const Duration(milliseconds: 60),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isDeciding
                                  ? null
                                  : () => _decide(
                                      VerificationStatus.rejected,
                                      name,
                                    ),
                              icon: const Icon(Icons.close),
                              label: const Text('Reject'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _isDeciding
                                  ? null
                                  : () => _decide(
                                      VerificationStatus.approved,
                                      name,
                                    ),
                              icon: const Icon(Icons.check),
                              label: const Text('Verify'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if ((profile?.bio ?? '').isNotEmpty) ...[
                    const SizedBox(height: 20),
                    StaggeredFadeIn(
                      delay: const Duration(milliseconds: 120),
                      child: Text(
                        profile!.bio!,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  StaggeredFadeIn(
                    delay: const Duration(milliseconds: 180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact', style: AppTextStyles.titleSmall),
                        const SizedBox(height: 8),
                        _Card(
                          children: [
                            AdminDetailRow(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: user.email?.isNotEmpty == true
                                  ? user.email!
                                  : '—',
                            ),
                            AdminDetailRow(
                              icon: Icons.phone_outlined,
                              label: 'Phone',
                              value: user.phone?.isNotEmpty == true
                                  ? user.phone!
                                  : '—',
                              isLast: profile?.companySize == null,
                            ),
                            if (profile?.companySize != null)
                              AdminDetailRow(
                                icon: Icons.groups_outlined,
                                label: 'Company size',
                                value: profile!.companySize!,
                                isLast: true,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (profile != null && profile.categories.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    StaggeredFadeIn(
                      delay: const Duration(milliseconds: 240),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Industries', style: AppTextStyles.titleSmall),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.categories
                                .map((category) => Chip(label: Text(category)))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if ((profile?.website ?? '').isNotEmpty ||
                      (profile?.linkedinUrl ?? '').isNotEmpty) ...[
                    const SizedBox(height: 20),
                    StaggeredFadeIn(
                      delay: const Duration(milliseconds: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Links', style: AppTextStyles.titleSmall),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if ((profile?.website ?? '').isNotEmpty)
                                IconButton(
                                  onPressed: () => _launch(profile!.website),
                                  icon: const Icon(Icons.public),
                                ),
                              if ((profile?.linkedinUrl ?? '').isNotEmpty)
                                IconButton(
                                  onPressed: () =>
                                      _launch(profile!.linkedinUrl),
                                  icon: const LinkedInIcon(
                                    size: 28,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (isSuperAdmin) ...[
                    const SizedBox(height: 20),
                    StaggeredFadeIn(
                      delay: const Duration(milliseconds: 360),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Danger Zone',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _Card(
                            children: [
                              if (user.suspended)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Account suspended',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                  subtitle: Text(
                                    (user.suspendedReason ?? '').isNotEmpty
                                        ? user.suspendedReason!
                                        : 'This account can no longer sign in.',
                                  ),
                                  trailing: OutlinedButton(
                                    onPressed: isModerating
                                        ? null
                                        : () => _reinstate(name),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: Size.zero,
                                    ),
                                    child: const Text('Reinstate'),
                                  ),
                                )
                              else
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Suspend account'),
                                  subtitle: const Text(
                                    'Immediately blocks sign-in. Use for '
                                    'Terms of Service violations.',
                                  ),
                                  trailing: OutlinedButton(
                                    onPressed: isModerating
                                        ? null
                                        : () => _suspend(name),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: Size.zero,
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(
                                        color: AppColors.error,
                                      ),
                                    ),
                                    child: const Text('Suspend'),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AdminColors.border(context)),
      ),
      child: Column(children: children),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.status});

  final VerificationStatus status;

  Color get _color => switch (status) {
    VerificationStatus.approved => AppColors.success,
    VerificationStatus.pending => AppColors.info,
    VerificationStatus.rejected => AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.micro.copyWith(
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
