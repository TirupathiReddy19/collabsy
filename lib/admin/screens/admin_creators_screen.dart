import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../features/auth/models/app_user_profile.dart';
import '../../features/creator/models/creator_profile.dart';
import '../../features/creator/providers/creator_profile_providers.dart';
import '../../features/notifications/models/notification_type.dart';
import '../../features/notifications/providers/notifications_providers.dart';
import '../../features/settings/models/instagram_account.dart';
import '../../features/settings/providers/instagram_providers.dart';
import '../../shared/models/user_role.dart';
import '../../shared/models/verification_status.dart';
import '../models/audit_log.dart';
import '../providers/admin_audit_log_providers.dart';
import '../providers/admin_auth_providers.dart';
import '../providers/admin_users_providers.dart';
import '../utils/admin_dialog.dart';
import '../utils/creator_display_name.dart';
import '../widgets/admin_row_skeleton.dart';
import '../widgets/admin_top_bar.dart';
import '../theme/admin_colors.dart';

class AdminCreatorsScreen extends ConsumerStatefulWidget {
  const AdminCreatorsScreen({super.key}) : lockedVerificationStatus = null;

  /// Used by the sidebar's "Verification Queue" page — fixes the list to
  /// one verification status and hides the filter chips entirely, since
  /// there's nothing left to choose.
  const AdminCreatorsScreen.locked({
    super.key,
    required VerificationStatus status,
  }) : lockedVerificationStatus = status;

  final VerificationStatus? lockedVerificationStatus;

  @override
  ConsumerState<AdminCreatorsScreen> createState() =>
      _AdminCreatorsScreenState();
}

class _AdminCreatorsScreenState extends ConsumerState<AdminCreatorsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  VerificationStatus? _verificationFilter;
  final Set<String> _selectedIds = {};
  bool _isBulkActing = false;

  @override
  void initState() {
    super.initState();
    // Set here, not as a field initializer — `widget` isn't attached yet
    // at field-initialization time.
    _verificationFilter = widget.lockedVerificationStatus;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _bulkDecide(VerificationStatus status) async {
    final label = status == VerificationStatus.approved ? 'Approve' : 'Reject';
    final confirmed = await showAdminDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$label ${_selectedIds.length} creators?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(label),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isBulkActing = true);
    final ids = _selectedIds.toList();
    final userList =
        ref.read(usersByRoleProvider(UserRole.creator)).value ?? const [];
    final userById = {for (final user in userList) user.id: user};
    final instagramMap = {
      for (final account
          in ref.read(allInstagramAccountsProvider).value ?? const [])
        account.id: account,
    };
    final actorEmail = ref.read(currentAdminEmailProvider) ?? adminEmail;
    var succeeded = 0;
    for (final id in ids) {
      final user = userById[id];
      if (user == null) continue;
      final name = creatorDisplayNameFor(user, instagramMap[id]);
      try {
        await ref
            .read(creatorProfileRepositoryProvider)
            .setVerificationStatus(userId: id, status: status);
        await ref
            .read(notificationsRepositoryProvider)
            .create(
              userId: id,
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
              referenceId: id,
            );
        await ref
            .read(adminAuditLogRepositoryProvider)
            .log(
              actorEmail: actorEmail,
              action: status == VerificationStatus.approved
                  ? AuditLogAction.creatorVerified
                  : AuditLogAction.creatorRejected,
              targetId: id,
              targetName: name,
            );
        succeeded++;
      } catch (_) {
        // Continue with the rest — the final snackbar reports how many of
        // the selection actually went through.
      }
    }
    ref.invalidate(creatorDirectoryProvider);
    if (!mounted) return;
    setState(() {
      _selectedIds.clear();
      _isBulkActing = false;
    });
    final verb = status == VerificationStatus.approved
        ? 'Approved'
        : 'Rejected';
    if (succeeded == ids.length) {
      AppSnackbar.showSuccess(context, '$verb $succeeded creators.');
    } else {
      AppSnackbar.showError(
        context,
        '$verb $succeeded of ${ids.length} creators — some failed.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersByRoleProvider(UserRole.creator));
    final profiles = ref.watch(creatorDirectoryProvider);
    final instagramAccounts = ref.watch(allInstagramAccountsProvider);
    final locked = widget.lockedVerificationStatus != null;
    // Approve/reject only makes sense for still-pending accounts, so
    // selection only appears when that's the active filter — no separate
    // "select mode" toggle needed.
    final selectable = _verificationFilter == VerificationStatus.pending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminTopBar(
          title: locked ? 'Verification Queue' : 'Creators',
          subtitle: locked
              ? 'Creators waiting on your decision'
              : 'Everyone signed up on the Creator side',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: const InputDecoration(
              hintText: 'Search by name or email',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        if (!locked) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Row(
              children: [
                _VerificationFilterChip(
                  label: 'All',
                  selected: _verificationFilter == null,
                  onTap: () => setState(() => _verificationFilter = null),
                ),
                const SizedBox(width: 8),
                for (final status in VerificationStatus.values) ...[
                  _VerificationFilterChip(
                    label: status.label,
                    selected: _verificationFilter == status,
                    onTap: () => setState(() => _verificationFilter = status),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: users.when(
            loading: () => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: AdminListSkeleton(
                rowBuilder: (_) => const AdminAvatarRowSkeleton(),
              ),
            ),
            error: (error, _) => Center(child: Text('Failed to load: $error')),
            data: (userList) {
              final profileMap = {
                for (final profile in profiles.value ?? <CreatorProfile>[])
                  profile.id: profile,
              };
              final instagramMap = {
                for (final account
                    in instagramAccounts.value ?? <InstagramAccount>[])
                  account.id: account,
              };
              final filtered =
                  userList.where((user) {
                    final profile = profileMap[user.id];
                    if (_verificationFilter != null &&
                        (profile?.verificationStatus ??
                                VerificationStatus.pending) !=
                            _verificationFilter) {
                      return false;
                    }
                    if (_query.isEmpty) return true;
                    final q = _query.toLowerCase();
                    final instagram = instagramMap[user.id];
                    return (user.displayName?.toLowerCase().contains(q) ??
                            false) ||
                        (user.email?.toLowerCase().contains(q) ?? false) ||
                        (instagram?.username?.toLowerCase().contains(q) ??
                            false);
                  }).toList()..sort(
                    (a, b) => creatorDisplayNameFor(
                      a,
                      instagramMap[a.id],
                    ).compareTo(creatorDisplayNameFor(b, instagramMap[b.id])),
                  );

              if (filtered.isEmpty) {
                return const EmptyState(
                  icon: Icons.people_outline,
                  title: 'No creators found',
                  subtitle: 'Try a different search.',
                );
              }

              final filteredIds = filtered.map((u) => u.id).toSet();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectable)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${_selectedIds.length} selected',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AdminColors.textSecondary(context),
                            ),
                          ),
                          const Spacer(),
                          // IntrinsicWidth: a Material button as a bare Row
                          // child alongside a Spacer can be handed an
                          // infinite-width constraint and crash the whole
                          // screen's layout — same fix as AdminTopBar's
                          // `actions` slot.
                          IntrinsicWidth(
                            child: TextButton(
                              onPressed: () => setState(
                                () => _selectedIds.addAll(filteredIds),
                              ),
                              child: const Text('Select all'),
                            ),
                          ),
                          IntrinsicWidth(
                            child: TextButton(
                              onPressed: _selectedIds.isEmpty
                                  ? null
                                  : () => setState(_selectedIds.clear),
                              child: const Text('Clear'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final user = filtered[index];
                        return StaggeredFadeIn(
                          key: ValueKey(user.id),
                          delay: Duration(
                            milliseconds: (index * 40).clamp(0, 400),
                          ),
                          child: _CreatorRow(
                            user: user,
                            profile: profileMap[user.id],
                            instagram: instagramMap[user.id],
                            selectable: selectable,
                            selected: _selectedIds.contains(user.id),
                            onSelectedChanged: (value) => setState(() {
                              if (value) {
                                _selectedIds.add(user.id);
                              } else {
                                _selectedIds.remove(user.id);
                              }
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (_selectedIds.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AdminColors.surface(context),
              border: Border(
                top: BorderSide(color: AdminColors.border(context)),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '${_selectedIds.length} selected',
                  style: AppTextStyles.bodyMedium,
                ),
                const Spacer(),
                // IntrinsicWidth: a Material button as a bare Row child
                // alongside a Spacer can be handed an infinite-width
                // constraint and crash the whole screen's layout — same fix
                // as AdminTopBar's `actions` slot.
                IntrinsicWidth(
                  child: OutlinedButton(
                    onPressed: _isBulkActing
                        ? null
                        : () => _bulkDecide(VerificationStatus.rejected),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 8),
                IntrinsicWidth(
                  child: FilledButton(
                    onPressed: _isBulkActing
                        ? null
                        : () => _bulkDecide(VerificationStatus.approved),
                    child: _isBulkActing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: LoadingIndicator(
                              size: 16,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Approve'),
                  ),
                ),
              ],
            ),
          )
        else
          const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _CreatorRow extends StatelessWidget {
  const _CreatorRow({
    required this.user,
    required this.profile,
    required this.instagram,
    this.selectable = false,
    this.selected = false,
    this.onSelectedChanged,
  });

  final AppUserProfile user;
  final CreatorProfile? profile;
  final InstagramAccount? instagram;
  final bool selectable;
  final bool selected;
  final ValueChanged<bool>? onSelectedChanged;

  @override
  Widget build(BuildContext context) {
    final location = [
      profile?.city,
      profile?.state,
    ].whereType<String>().where((s) => s.isNotEmpty).join(', ');
    final displayedName = creatorDisplayNameFor(user, instagram);
    // Shown as a subtitle whenever the main name isn't already just the
    // handle itself (that only happens when there's no display name and no
    // Instagram name, so the handle became the name via
    // creatorDisplayNameFor and repeating it here would be redundant).
    final showInstagramHandle =
        instagram?.username?.isNotEmpty == true &&
        displayedName != '@${instagram!.username}';

    // A plain icon + GestureDetector, not the Material `Checkbox` widget —
    // `Checkbox` carries its own ink-response/hover-tracking render objects
    // (RenderMouseRegion/_RenderInkFeatures), and "Select all" flips
    // potentially dozens of them in a single frame, which is a known
    // trigger for a Flutter Web MouseTracker hit-test crash. A bare Icon
    // has none of that machinery.
    return Row(
      children: [
        if (selectable)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelectedChanged?.call(!selected),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                selected ? Icons.check_box : Icons.check_box_outline_blank,
                color: selected
                    ? AppColors.primary
                    : AdminColors.textSecondary(context),
              ),
            ),
          ),
        Expanded(
          child: Material(
            color: AdminColors.surface(context),
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              onTap: () => context.push('/creators/${user.id}'),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.card),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  border: Border.all(color: AdminColors.border(context)),
                ),
                child: Row(
                  children: [
                    ProfileAvatar(
                      avatarUrl: instagram?.profilePictureUrl ?? user.avatarUrl,
                      fallbackIcon: Icons.person,
                      radius: 22,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayedName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (user.email != null || showInstagramHandle)
                            Text(
                              [
                                if (user.email != null) user.email!,
                                if (showInstagramHandle)
                                  '@${instagram!.username}',
                              ].join(' · '),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AdminColors.textSecondary(context),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        user.phone?.isNotEmpty == true ? user.phone! : '—',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        location.isEmpty ? '—' : location,
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        profile == null || profile!.categories.isEmpty
                            ? '—'
                            : profile!.categories.join(', '),
                        style: AppTextStyles.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _VerificationBadge(
                      status:
                          profile?.verificationStatus ??
                          VerificationStatus.pending,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VerificationFilterChip extends StatelessWidget {
  const _VerificationFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryLight,
      labelStyle: TextStyle(
        color: selected
            ? AppColors.primary
            : AdminColors.textSecondary(context),
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: selected ? AppColors.primary : AdminColors.border(context),
      ),
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
