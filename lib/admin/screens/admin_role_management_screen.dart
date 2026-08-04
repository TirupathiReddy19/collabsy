import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../models/admin_nav_item.dart';
import '../models/audit_log.dart';
import '../models/staff_account.dart';
import '../providers/admin_audit_log_providers.dart';
import '../providers/admin_auth_providers.dart';
import '../providers/admin_role_providers.dart';
import '../providers/admin_staff_login_event_providers.dart';
import '../utils/admin_dialog.dart';
import '../widgets/admin_top_bar.dart';
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

String _fmtDateTime(DateTime? time) {
  if (time == null) return '—';
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour < 12 ? 'AM' : 'PM';
  return '${_fmtDate(time)}, $hour:$minute $period';
}

String _labelForPath(String path) {
  for (final group in adminNavGroups) {
    for (final item in group.items) {
      if (item.path == path) return item.label;
    }
  }
  return path;
}

/// Every sidebar item except Role Management and Reports — both are
/// never toggleable permissions, only the super admin can ever reach them
/// (Reports reads across data gated behind several other sections' own
/// specific permissions, so it can't safely be granted piecemeal).
List<AdminNavItem> _toggleableItems() => adminNavGroups
    .expand((group) => group.items)
    .where((item) => item.path != '/roles' && item.path != '/reports')
    .toList();

/// Super-admin-only screen for creating and managing staff logins whose
/// access is limited to whichever sidebar sections they're toggled on for.
class AdminRoleManagementScreen extends ConsumerWidget {
  const AdminRoleManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(allStaffAccountsProvider);
    final lastSignIn =
        ref.watch(staffLastSignInProvider).value ?? <String, DateTime?>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminTopBar(
          title: 'Role Management',
          subtitle: 'Staff logins with limited, toggleable access',
          actions: [
            FilledButton.icon(
              onPressed: () => showAdminDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const _CreateRoleDialog(),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Create Role'),
            ),
          ],
        ),
        Expanded(
          child: staffAsync.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, _) => Center(child: Text('Failed to load: $error')),
            data: (accounts) {
              if (accounts.isEmpty) {
                return const EmptyState(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'No staff accounts yet',
                  subtitle: 'Create one to give someone limited admin access.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                itemCount: accounts.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => _StaffRow(
                  account: accounts[index],
                  lastSignIn: lastSignIn[accounts[index].uid],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _StaffRow extends ConsumerWidget {
  const _StaffRow({required this.account, required this.lastSignIn});

  final StaffAccount account;
  final DateTime? lastSignIn;

  Future<void> _forceLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAdminDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Force logout "${account.roleName}"?'),
        content: Text(
          '${account.email} will be signed out of the admin portal and '
          'required to log in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Force logout'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(adminRoleRepositoryProvider).forceLogout(account.uid);
      await ref
          .read(adminAuditLogRepositoryProvider)
          .log(
            actorEmail: ref.read(currentAdminEmailProvider) ?? adminEmail,
            action: AuditLogAction.staffAccountForcedLogout,
            targetId: account.email,
            targetName: account.roleName,
          );
      if (!context.mounted) return;
      AppSnackbar.showSuccess(context, 'Signed out "${account.roleName}".');
    } catch (_) {
      if (!context.mounted) return;
      AppSnackbar.showError(context, "Couldn't force logout.");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledLabels = account.permissions.entries
        .where((entry) => entry.value)
        .map((entry) => _labelForPath(entry.key))
        .join(', ');

    return Material(
      color: AdminColors.surface(context),
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.card),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(color: AdminColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.badge_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.roleName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    account.email,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AdminColors.textSecondary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                enabledLabels.isEmpty ? 'No features assigned' : enabledLabels,
                style: AppTextStyles.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 190,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Joined ${_fmtDate(account.createdAt)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AdminColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lastSignIn == null
                        ? 'Never logged in'
                        : 'Last login ${_fmtDateTime(lastSignIn)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AdminColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.history, size: 20),
              tooltip: 'Login history',
              color: AdminColors.textSecondary(context),
              onPressed: () => showAdminDialog(
                context: context,
                builder: (_) => _LoginHistoryDialog(account: account),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Edit access',
              color: AdminColors.textSecondary(context),
              onPressed: () => showAdminDialog(
                context: context,
                builder: (_) => _EditPermissionsDialog(account: account),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, size: 20),
              tooltip: 'Force logout',
              color: AppColors.error,
              onPressed: () => _forceLogout(context, ref),
            ),
            Switch(
              value: account.active,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => ref
                  .read(adminRoleRepositoryProvider)
                  .setActive(account.uid, value),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full login/logout session history for one staff account — Firebase Auth
/// itself only ever exposes the single latest sign-in, so this reads from
/// `staffLoginEvents`, written at each real sign-in/sign-out (see
/// `admin_login_screen.dart`, `admin_sidebar.dart`, `admin_no_access_screen
/// .dart`, and the `forceLogoutStaffAccount` Cloud Function).
class _LoginHistoryDialog extends ConsumerWidget {
  const _LoginHistoryDialog({required this.account});

  final StaffAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(staffLoginEventsProvider(account.uid));

    return AlertDialog(
      title: Text('${account.roleName} — login history'),
      content: SizedBox(
        width: 360,
        child: eventsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: LoadingIndicator()),
          ),
          error: (error, _) => Text('Failed to load: $error'),
          data: (events) {
            if (events.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No activity yet.'),
              );
            }
            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: events.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final event = events[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(event.type.icon, size: 20),
                    title: Text(
                      event.type.label,
                      style: AppTextStyles.bodyMedium,
                    ),
                    subtitle: Text(
                      _fmtDateTime(event.timestamp),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AdminColors.textSecondary(context),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Revises an existing staff account's access — the only way to grant it a
/// sidebar section that didn't exist yet (or didn't get toggled on) when
/// the role was first created via [_CreateRoleDialog].
class _EditPermissionsDialog extends ConsumerStatefulWidget {
  const _EditPermissionsDialog({required this.account});

  final StaffAccount account;

  @override
  ConsumerState<_EditPermissionsDialog> createState() =>
      _EditPermissionsDialogState();
}

class _EditPermissionsDialogState
    extends ConsumerState<_EditPermissionsDialog> {
  late final Map<String, bool> _permissions = Map.of(
    widget.account.permissions,
  );
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(adminRoleRepositoryProvider)
          .updatePermissions(widget.account.uid, _permissions);
      await ref
          .read(adminAuditLogRepositoryProvider)
          .log(
            actorEmail: ref.read(currentAdminEmailProvider) ?? adminEmail,
            action: AuditLogAction.staffPermissionsUpdated,
            targetId: widget.account.email,
            targetName: widget.account.roleName,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.showSuccess(context, 'Access updated.');
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't update access.");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Access', style: AppTextStyles.heading2),
              const SizedBox(height: 4),
              Text(
                widget.account.roleName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AdminColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: _PermissionsStep(
                    items: _toggleableItems(),
                    permissions: _permissions,
                    onChanged: (path, value) =>
                        setState(() => _permissions[path] = value),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateRoleDialog extends ConsumerStatefulWidget {
  const _CreateRoleDialog();

  @override
  ConsumerState<_CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends ConsumerState<_CreateRoleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleNameController = TextEditingController();
  final Map<String, bool> _permissions = {};
  int _step = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _roleNameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0 && !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _step += 1);
  }

  void _back() => setState(() => _step -= 1);

  Future<void> _create() async {
    final roleName = _roleNameController.text.trim();
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(adminRoleRepositoryProvider)
          .createStaffAccount(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            roleName: roleName,
            permissions: _permissions,
          );
      await ref
          .read(adminAuditLogRepositoryProvider)
          .log(
            actorEmail: ref.read(currentAdminEmailProvider) ?? adminEmail,
            action: AuditLogAction.staffAccountCreated,
            targetId: _emailController.text.trim(),
            targetName: roleName,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.showSuccess(context, 'Role "$roleName" created.');
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, e.message ?? "Couldn't create the role.");
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't create the role.");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _toggleableItems();
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Role', style: AppTextStyles.heading2),
              const SizedBox(height: 4),
              Text(
                'Step ${_step + 1} of 3',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AdminColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: switch (_step) {
                    0 => _IdentityStep(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      roleNameController: _roleNameController,
                    ),
                    1 => _PermissionsStep(
                      items: items,
                      permissions: _permissions,
                      onChanged: (path, value) =>
                          setState(() => _permissions[path] = value),
                    ),
                    _ => _ReviewStep(
                      email: _emailController.text.trim(),
                      roleName: _roleNameController.text.trim(),
                      enabledLabels: items
                          .where((item) => _permissions[item.path] == true)
                          .map((item) => item.label)
                          .toList(),
                    ),
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_step > 0)
                    TextButton(
                      onPressed: _isSubmitting ? null : _back,
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  if (_step < 2)
                    FilledButton(onPressed: _next, child: const Text('Next'))
                  else
                    FilledButton(
                      onPressed: _isSubmitting ? null : _create,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Create Role'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentityStep extends StatelessWidget {
  const _IdentityStep({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.roleNameController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController roleNameController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: roleNameController,
            label: 'Role name',
            hintText: 'e.g. Support, Reviewer',
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter a role name'
                : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter an email'
                : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: passwordController,
            label: 'Temporary password',
            obscureText: true,
            validator: (value) => (value == null || value.length < 6)
                ? 'At least 6 characters'
                : null,
          ),
        ],
      ),
    );
  }
}

class _PermissionsStep extends StatelessWidget {
  const _PermissionsStep({
    required this.items,
    required this.permissions,
    required this.onChanged,
  });

  final List<AdminNavItem> items;
  final Map<String, bool> permissions;
  final void Function(String path, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in adminNavGroups)
          if (group.items.any((item) => item.path != '/roles')) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                group.title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AdminColors.textSecondary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (final item in group.items)
              if (item.path != '/roles')
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(item.label, style: AppTextStyles.bodyMedium),
                  value: permissions[item.path] ?? false,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) => onChanged(item.path, value),
                ),
          ],
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.email,
    required this.roleName,
    required this.enabledLabels,
  });

  final String email;
  final String roleName;
  final List<String> enabledLabels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role name',
          style: AppTextStyles.bodySmall.copyWith(
            color: AdminColors.textSecondary(context),
          ),
        ),
        Text(roleName, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 12),
        Text(
          'Email',
          style: AppTextStyles.bodySmall.copyWith(
            color: AdminColors.textSecondary(context),
          ),
        ),
        Text(email, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 12),
        Text(
          'Access',
          style: AppTextStyles.bodySmall.copyWith(
            color: AdminColors.textSecondary(context),
          ),
        ),
        if (enabledLabels.isEmpty)
          Text(
            'No features toggled on — this account won\'t be able to see anything until you edit it.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
          )
        else
          for (final label in enabledLabels)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(label, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
      ],
    );
  }
}
