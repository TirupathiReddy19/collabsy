import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/campaign_categories.dart';
import '../../core/utils/company_size_options.dart';
import '../../core/utils/india_regions.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../features/auth/models/app_user_profile.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/brand/models/brand_profile.dart';
import '../../shared/models/verification_status.dart';
import '../../features/brand/providers/brand_profile_providers.dart';
import '../../features/notifications/models/notification_type.dart';
import '../../features/notifications/providers/notifications_providers.dart';
import '../../shared/models/user_role.dart';
import '../models/audit_log.dart';
import '../providers/admin_audit_log_providers.dart';
import '../providers/admin_auth_providers.dart';
import '../providers/admin_users_providers.dart';
import '../utils/admin_dialog.dart';
import '../utils/csv_download.dart';
import '../widgets/admin_row_skeleton.dart';
import '../widgets/admin_top_bar.dart';
import '../theme/admin_colors.dart';

class AdminBrandsScreen extends ConsumerStatefulWidget {
  const AdminBrandsScreen({super.key}) : lockedVerificationStatus = null;

  /// Used by the sidebar's "Verification Queue" page — fixes the list to
  /// one verification status and hides the filter chips entirely, since
  /// there's nothing left to choose.
  const AdminBrandsScreen.locked({
    super.key,
    required VerificationStatus status,
  }) : lockedVerificationStatus = status;

  final VerificationStatus? lockedVerificationStatus;

  @override
  ConsumerState<AdminBrandsScreen> createState() => _AdminBrandsScreenState();
}

typedef _BrandFilters = ({
  DateTime? signupFrom,
  DateTime? signupTo,
  String? state,
  String city,
  Set<String> categories,
  String? companySize,
  String companyName,
});

const _emptyBrandFilters = (
  signupFrom: null,
  signupTo: null,
  state: null,
  city: '',
  categories: <String>{},
  companySize: null,
  companyName: '',
);

class _AdminBrandsScreenState extends ConsumerState<AdminBrandsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  VerificationStatus? _verificationFilter;
  _BrandFilters _filters = _emptyBrandFilters;
  final Set<String> _selectedIds = {};
  bool _isBulkActing = false;
  bool _isExporting = false;

  // Set during build()'s data callback, read by the Export CSV button in
  // the top bar above it — same reasoning as the Creators screen.
  List<AppUserProfile>? _lastFiltered;
  Map<String, BrandProfile>? _lastProfileMap;

  int get _activeFilterCount {
    var count = 0;
    if (_filters.signupFrom != null || _filters.signupTo != null) count++;
    if (_filters.state != null) count++;
    if (_filters.city.isNotEmpty) count++;
    if (_filters.categories.isNotEmpty) count++;
    if (_filters.companySize != null) count++;
    if (_filters.companyName.isNotEmpty) count++;
    return count;
  }

  Future<void> _openFilters() async {
    final result = await showDialog<_BrandFilters>(
      context: context,
      builder: (context) => _BrandFiltersDialog(initial: _filters),
    );
    if (result != null) setState(() => _filters = result);
  }

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

  String _brandName(AppUserProfile user) =>
      user.displayName?.isNotEmpty == true ? user.displayName! : 'Unnamed user';

  Future<void> _bulkDecide(VerificationStatus status) async {
    final label = status == VerificationStatus.approved ? 'Approve' : 'Reject';
    final confirmed = await showAdminDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$label ${_selectedIds.length} brands?'),
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
        ref.read(usersByRoleProvider(UserRole.brand)).value ?? const [];
    final userById = {for (final user in userList) user.id: user};
    final actorEmail = ref.read(currentAdminEmailProvider) ?? adminEmail;
    var succeeded = 0;
    for (final id in ids) {
      final user = userById[id];
      if (user == null) continue;
      final name = _brandName(user);
      try {
        await ref
            .read(brandProfileRepositoryProvider)
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
                  ? 'Your brand profile has been verified.'
                  : 'Your brand profile could not be verified.',
              referenceType: 'brand',
              referenceId: id,
            );
        await ref
            .read(adminAuditLogRepositoryProvider)
            .log(
              actorEmail: actorEmail,
              action: status == VerificationStatus.approved
                  ? AuditLogAction.brandVerified
                  : AuditLogAction.brandRejected,
              targetId: id,
              targetName: name,
            );
        succeeded++;
      } catch (_) {
        // Continue with the rest — the final snackbar reports how many of
        // the selection actually went through.
      }
    }
    ref.invalidate(brandDirectoryProvider);
    if (!mounted) return;
    setState(() {
      _selectedIds.clear();
      _isBulkActing = false;
    });
    final verb = status == VerificationStatus.approved
        ? 'Approved'
        : 'Rejected';
    if (succeeded == ids.length) {
      AppSnackbar.showSuccess(context, '$verb $succeeded brands.');
    } else {
      AppSnackbar.showError(
        context,
        '$verb $succeeded of ${ids.length} brands — some failed.',
      );
    }
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Exports exactly the currently filtered/searched list, not every
  /// brand — matches what the admin is actually looking at.
  Future<void> _exportCsv(
    List<AppUserProfile> filtered,
    Map<String, BrandProfile> profileMap,
    Map<String, Map<String, dynamic>> privateContacts,
  ) async {
    setState(() => _isExporting = true);
    try {
      final rows = <String>[
        'Contact name,Company,Email,Phone,Verification,Website,City,State,Categories',
      ];
      for (final user in filtered) {
        final profile = profileMap[user.id];
        final contact = privateContacts[user.id];
        rows.add(
          [
            _brandName(user),
            profile?.companyName ?? '',
            contact?['email'] as String? ?? '',
            contact?['phone'] as String? ?? '',
            (profile?.verificationStatus ?? VerificationStatus.pending).label,
            profile?.website ?? '',
            profile?.city ?? '',
            profile?.state ?? '',
            profile?.categories.join('; ') ?? '',
          ].map(_csvEscape).join(','),
        );
      }
      downloadCsv(
        'collabsy-brands-${DateTime.now().toIso8601String().split('T').first}.csv',
        rows.join('\n'),
      );
      if (mounted) AppSnackbar.showSuccess(context, 'Exported ${filtered.length} brands.');
    } catch (_) {
      if (mounted) AppSnackbar.showError(context, "Couldn't export the list.");
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersByRoleProvider(UserRole.brand));
    final profiles = ref.watch(brandDirectoryProvider);
    final privateContacts =
        ref.watch(privateContactsByRoleProvider(UserRole.brand)).value ??
        const {};
    final locked = widget.lockedVerificationStatus != null;
    // Approve/reject only makes sense for still-pending accounts, so
    // selection only appears when that's the active filter — no separate
    // "select mode" toggle needed.
    final selectable = _verificationFilter == VerificationStatus.pending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminTopBar(
          title: locked ? 'Verification Queue' : 'Brands & Agencies',
          subtitle: locked
              ? 'Brands waiting on your decision'
              : 'Everyone signed up on the Brand side',
          actions: [
            TextButton.icon(
              onPressed: _openFilters,
              icon: const Icon(Icons.filter_list, size: 18),
              label: Text(
                _activeFilterCount == 0
                    ? 'Filters'
                    : 'Filters ($_activeFilterCount)',
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _isExporting || _lastFiltered == null
                  ? null
                  : () => _exportCsv(
                      _lastFiltered!,
                      _lastProfileMap!,
                      privateContacts,
                    ),
              icon: _isExporting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined, size: 18),
              label: const Text('Export CSV'),
            ),
          ],
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
                for (final profile in profiles.value ?? <BrandProfile>[])
                  profile.id: profile,
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
                    if (_filters.signupFrom != null &&
                        (user.createdAt == null ||
                            user.createdAt!.isBefore(_filters.signupFrom!))) {
                      return false;
                    }
                    if (_filters.signupTo != null &&
                        (user.createdAt == null ||
                            user.createdAt!.isAfter(_filters.signupTo!))) {
                      return false;
                    }
                    if (_filters.state != null &&
                        profile?.state != _filters.state) {
                      return false;
                    }
                    if (_filters.city.isNotEmpty &&
                        !(profile?.city ?? '').toLowerCase().contains(
                          _filters.city.toLowerCase(),
                        )) {
                      return false;
                    }
                    if (_filters.categories.isNotEmpty &&
                        !_filters.categories.any(
                          (c) => (profile?.categories ?? const []).contains(c),
                        )) {
                      return false;
                    }
                    if (_filters.companySize != null &&
                        profile?.companySize != _filters.companySize) {
                      return false;
                    }
                    if (_filters.companyName.isNotEmpty &&
                        !(profile?.companyName ?? '').toLowerCase().contains(
                          _filters.companyName.toLowerCase(),
                        )) {
                      return false;
                    }
                    if (_query.isEmpty) return true;
                    final q = _query.toLowerCase();
                    // U1 phase B: email no longer lives on the public doc —
                    // match against the bulk-loaded private contact map
                    // instead (see privateContactsByRoleProvider).
                    final email =
                        privateContacts[user.id]?['email'] as String?;
                    return (user.displayName?.toLowerCase().contains(q) ??
                            false) ||
                        (email?.toLowerCase().contains(q) ?? false) ||
                        (profile?.companyName?.toLowerCase().contains(q) ??
                            false);
                  }).toList()..sort(
                    (a, b) =>
                        (a.displayName ?? '').compareTo(b.displayName ?? ''),
                  );
              _lastFiltered = filtered;
              _lastProfileMap = profileMap;

              if (filtered.isEmpty) {
                return const EmptyState(
                  icon: Icons.business_outlined,
                  title: 'No brands found',
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
                          child: _BrandRow(
                            user: user,
                            profile: profileMap[user.id],
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

class _BrandRow extends ConsumerWidget {
  const _BrandRow({
    required this.user,
    required this.profile,
    this.selectable = false,
    this.selected = false,
    this.onSelectedChanged,
  });

  final AppUserProfile user;
  final BrandProfile? profile;
  final bool selectable;
  final bool selected;
  final ValueChanged<bool>? onSelectedChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // U1 phase A: email/phone moved to private/contact + private/phone,
    // admin-readable per their rules.
    final email =
        ref.watch(privateContactByIdProvider(user.id)).value?['email']
            as String?;
    final phone = ref.watch(privatePhoneByIdProvider(user.id)).value;
    final location = [
      profile?.city,
      profile?.state,
    ].whereType<String>().where((s) => s.isNotEmpty).join(', ');

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
              onTap: () => context.push('/brands/${user.id}'),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.card),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  border: Border.all(color: AdminColors.border(context)),
                ),
                child: Row(
                  children: [
                    ProfileAvatar(
                      avatarUrl: user.avatarUrl,
                      fallbackIcon: Icons.business,
                      radius: 22,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName?.isNotEmpty == true
                                ? user.displayName!
                                : 'Unnamed user',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if ([
                            profile?.companyName,
                            email,
                          ].any((s) => (s ?? '').isNotEmpty))
                            Text(
                              [
                                profile?.companyName,
                                email,
                              ].where((s) => (s ?? '').isNotEmpty).join(' · '),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AdminColors.textSecondary(context),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        phone?.isNotEmpty == true ? phone! : '—',
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

/// Edits a copy of the current filters, returning the new value on Apply
/// or `null` on Cancel/dismiss — mirrors `_CreatorFiltersDialog` on the
/// Creators screen, applied to both the on-screen list and CSV export.
class _BrandFiltersDialog extends StatefulWidget {
  const _BrandFiltersDialog({required this.initial});

  final _BrandFilters initial;

  @override
  State<_BrandFiltersDialog> createState() => _BrandFiltersDialogState();
}

class _BrandFiltersDialogState extends State<_BrandFiltersDialog> {
  late DateTime? _signupFrom = widget.initial.signupFrom;
  late DateTime? _signupTo = widget.initial.signupTo;
  late String? _state = widget.initial.state;
  late final _cityController = TextEditingController(
    text: widget.initial.city,
  );
  late final Set<String> _categories = {...widget.initial.categories};
  late String? _companySize = widget.initial.companySize;
  late final _companyNameController = TextEditingController(
    text: widget.initial.companyName,
  );

  @override
  void dispose() {
    _cityController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _signupFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _signupTo ?? DateTime.now(),
    );
    if (picked != null) setState(() => _signupFrom = picked);
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _signupTo ?? DateTime.now(),
      firstDate: _signupFrom ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _signupTo = picked);
  }

  String _fmtDate(DateTime? date) =>
      date == null ? 'Any' : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void _apply() {
    Navigator.of(context).pop((
      signupFrom: _signupFrom,
      signupTo: _signupTo,
      state: _state,
      city: _cityController.text.trim(),
      categories: _categories,
      companySize: _companySize,
      companyName: _companyNameController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter brands'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _companyNameController,
                label: 'Company name',
              ),
              const SizedBox(height: 16),
              Text('Signed up', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickFrom,
                      child: Text('From: ${_fmtDate(_signupFrom)}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickTo,
                      child: Text('To: ${_fmtDate(_signupTo)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('State', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _state,
                hint: const Text('Any'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Any')),
                  for (final state in indianStates)
                    DropdownMenuItem(value: state, child: Text(state)),
                ],
                onChanged: (value) => setState(() => _state = value),
              ),
              const SizedBox(height: 16),
              AppTextField(controller: _cityController, label: 'City'),
              const SizedBox(height: 16),
              Text('Company size', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _companySize,
                hint: const Text('Any'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Any')),
                  for (final size in companySizeOptions)
                    DropdownMenuItem(value: size, child: Text(size)),
                ],
                onChanged: (value) => setState(() => _companySize = value),
              ),
              const SizedBox(height: 16),
              Text('Categories', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: campaignCategories.map((category) {
                  final selected = _categories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: selected,
                    onSelected: (value) => setState(() {
                      if (value) {
                        _categories.add(category);
                      } else {
                        _categories.remove(category);
                      }
                    }),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_emptyBrandFilters),
          child: const Text('Clear all'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        PrimaryButton(text: 'Apply', onPressed: _apply, width: 100, height: 40),
      ],
    );
  }
}
