import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/creator/providers/creator_profile_providers.dart';
import '../../features/notifications/models/notification_type.dart';
import '../../features/notifications/providers/notifications_providers.dart';
import '../../features/settings/models/instagram_account.dart';
import '../../features/settings/providers/instagram_providers.dart';
import '../../shared/models/verification_status.dart';
import '../models/audit_log.dart';
import '../providers/admin_account_moderation_providers.dart';
import '../providers/admin_audit_log_providers.dart';
import '../providers/admin_auth_providers.dart';
import '../utils/creator_display_name.dart';
import '../widgets/admin_detail_row.dart';
import '../widgets/admin_top_bar.dart';
import '../widgets/suspend_account_dialog.dart';
import '../theme/admin_colors.dart';

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

String _fmtDate(DateTime? time) {
  if (time == null) return '—';
  return '${_months[time.month - 1]} ${time.day}, ${time.year}';
}

class AdminCreatorDetailScreen extends ConsumerStatefulWidget {
  const AdminCreatorDetailScreen({super.key, required this.creatorId});

  final String creatorId;

  @override
  ConsumerState<AdminCreatorDetailScreen> createState() =>
      _AdminCreatorDetailScreenState();
}

class _AdminCreatorDetailScreenState
    extends ConsumerState<AdminCreatorDetailScreen> {
  bool _isDeciding = false;

  Future<void> _decide(VerificationStatus status, String creatorName) async {
    setState(() => _isDeciding = true);
    try {
      await ref
          .read(creatorProfileRepositoryProvider)
          .setVerificationStatus(userId: widget.creatorId, status: status);
      await ref
          .read(notificationsRepositoryProvider)
          .create(
            userId: widget.creatorId,
            type: status == VerificationStatus.approved
                ? NotificationType.profileVerified
                : NotificationType.profileRejected,
            title: status == VerificationStatus.approved
                ? 'Profile verified'
                : 'Profile not verified',
            body: status == VerificationStatus.approved
                ? 'Your profile has been verified.'
                : 'Your profile could not be verified.',
            referenceType: 'creator',
            referenceId: widget.creatorId,
          );
      await ref
          .read(adminAuditLogRepositoryProvider)
          .log(
            actorEmail: ref.read(currentAdminEmailProvider) ?? adminEmail,
            action: status == VerificationStatus.approved
                ? AuditLogAction.creatorVerified
                : AuditLogAction.creatorRejected,
            targetId: widget.creatorId,
            targetName: creatorName,
          );
      // `creatorProfileByIdProvider` is a one-shot Future, not a live
      // stream — without this the badge and Approve/Reject buttons would
      // keep showing the pre-decision state until this screen happens to
      // get disposed and refetched.
      ref.invalidate(creatorProfileByIdProvider(widget.creatorId));
      if (!mounted) return;
      AppSnackbar.showSuccess(
        context,
        status == VerificationStatus.approved
            ? '$creatorName verified.'
            : '$creatorName rejected.',
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't update verification status.");
    } finally {
      if (mounted) setState(() => _isDeciding = false);
    }
  }

  Future<void> _suspend(String creatorName) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const SuspendAccountDialog(),
    );
    if (reason == null) return;
    if (!mounted) return;

    await ref
        .read(adminAccountModerationControllerProvider.notifier)
        .suspendAccount(
          uid: widget.creatorId,
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
          action: AuditLogAction.creatorSuspended,
          targetId: widget.creatorId,
          targetName: creatorName,
        );
    ref.invalidate(appUserProfileByIdProvider(widget.creatorId));
    if (!mounted) return;
    AppSnackbar.showSuccess(context, '$creatorName suspended.');
  }

  Future<void> _reinstate(String creatorName) async {
    await ref
        .read(adminAccountModerationControllerProvider.notifier)
        .reinstateAccount(widget.creatorId);
    if (!mounted) return;
    if (ref.read(adminAccountModerationControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't reinstate this account.");
      return;
    }
    await ref
        .read(adminAuditLogRepositoryProvider)
        .log(
          actorEmail: ref.read(currentAdminEmailProvider) ?? adminEmail,
          action: AuditLogAction.creatorReinstated,
          targetId: widget.creatorId,
          targetName: creatorName,
        );
    ref.invalidate(appUserProfileByIdProvider(widget.creatorId));
    if (!mounted) return;
    AppSnackbar.showSuccess(context, '$creatorName reinstated.');
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(appUserProfileByIdProvider(widget.creatorId));
    final profileAsync = ref.watch(
      creatorProfileByIdProvider(widget.creatorId),
    );
    final instagramAsync = ref.watch(
      instagramAccountForUserProvider(widget.creatorId),
    );
    final isSuperAdmin = ref.watch(isAdminProvider);
    final isModerating = ref
        .watch(adminAccountModerationControllerProvider)
        .isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminTopBar(
          title: 'Creator Profile',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/creators'),
          ),
        ),
        Expanded(
          child: userAsync.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, _) => Center(child: Text('Failed to load: $error')),
            data: (user) {
              if (user == null) {
                return const Center(child: Text('Creator not found.'));
              }
              final profile = profileAsync.value;
              final instagram = instagramAsync.value;
              final avatarUrl = instagram?.profilePictureUrl ?? user.avatarUrl;
              final location = [
                profile?.city,
                profile?.state,
                profile?.country,
              ].whereType<String>().where((s) => s.isNotEmpty).join(', ');
              final name = creatorDisplayNameFor(user, instagram);
              final verificationStatus =
                  profile?.verificationStatus ?? VerificationStatus.pending;

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                children: [
                  StaggeredFadeIn(
                    child: Row(
                      children: [
                        ProfileAvatar(
                          avatarUrl: avatarUrl,
                          fallbackIcon: Icons.person,
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
                              isLast: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  StaggeredFadeIn(
                    delay: const Duration(milliseconds: 240),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Instagram', style: AppTextStyles.titleSmall),
                        const SizedBox(height: 8),
                        if (instagram != null &&
                            instagram.status ==
                                InstagramConnectionStatus.connected)
                          _Card(
                            children: [
                              AdminDetailRow(
                                icon: Icons.alternate_email,
                                label: 'Username',
                                value: instagram.username?.isNotEmpty == true
                                    ? '@${instagram.username}'
                                    : '—',
                              ),
                              AdminDetailRow(
                                icon: Icons.groups_outlined,
                                label: 'Followers',
                                value: '${instagram.followersCount}',
                              ),
                              AdminDetailRow(
                                icon: Icons.person_add_alt_outlined,
                                label: 'Following',
                                value: '${instagram.followsCount}',
                              ),
                              AdminDetailRow(
                                icon: Icons.grid_on_outlined,
                                label: 'Posts',
                                value: '${instagram.mediaCount}',
                              ),
                              if ((instagram.biography ?? '').isNotEmpty)
                                AdminDetailRow(
                                  icon: Icons.notes_outlined,
                                  label: 'Bio',
                                  value: instagram.biography!,
                                ),
                              if ((instagram.website ?? '').isNotEmpty)
                                AdminDetailRow(
                                  icon: Icons.link,
                                  label: 'Website',
                                  value: instagram.website!,
                                ),
                              AdminDetailRow(
                                icon: Icons.event_outlined,
                                label: 'Connected on',
                                value: _fmtDate(instagram.connectedAt),
                                isLast: true,
                              ),
                            ],
                          )
                        else
                          _Card(
                            children: [
                              AdminDetailRow(
                                icon: Icons.link_off,
                                label: 'Status',
                                value: 'Not connected',
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
                      delay: const Duration(milliseconds: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Content categories',
                            style: AppTextStyles.titleSmall,
                          ),
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
                  if (profile != null && profile.languages.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    StaggeredFadeIn(
                      delay: const Duration(milliseconds: 360),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Languages', style: AppTextStyles.titleSmall),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.languages
                                .map((language) => Chip(label: Text(language)))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (isSuperAdmin) ...[
                    const SizedBox(height: 20),
                    StaggeredFadeIn(
                      delay: const Duration(milliseconds: 420),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.bodySmall.copyWith(
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
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
