import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/primary_button.dart';
import '../models/staff_account.dart';
import '../providers/admin_brand_prospects_providers.dart';
import '../providers/admin_role_providers.dart';
import '../theme/admin_colors.dart';
import '../utils/text_file_upload.dart';
import '../widgets/admin_top_bar.dart';

/// Admin's control panel over the bulk-imported brand research pool —
/// import the prepared JSON once, then push a category at a time to a
/// brand-outreach intern. The intern never sees the whole pool, only what
/// they've been pushed (see `brand_intern_prospects_providers.dart`'s "My
/// Prospects" tab) — this screen is the only place assignment happens.
class AdminBrandProspectsScreen extends ConsumerStatefulWidget {
  const AdminBrandProspectsScreen({super.key});

  @override
  ConsumerState<AdminBrandProspectsScreen> createState() =>
      _AdminBrandProspectsScreenState();
}

class _AdminBrandProspectsScreenState
    extends ConsumerState<AdminBrandProspectsScreen> {
  bool _isImporting = false;
  int _importWritten = 0;
  int _importTotal = 0;
  String? _pushingCategory;

  void _refresh() {
    ref.invalidate(brandProspectTotalImportedProvider);
    ref.invalidate(brandProspectCategoryBreakdownProvider);
  }

  Future<void> _import() async {
    final text = await pickTextFile(accept: '.json');
    if (text == null) return;

    List<dynamic> rows;
    try {
      rows = jsonDecode(text) as List<dynamic>;
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'That file is not valid JSON.');
      return;
    }

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import brand prospects'),
        content: Text(
          'This will write ${rows.length} prospects to brandProspects. '
          "Rows whose id already exists will be overwritten with the "
          "file's values. Continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            width: 100,
            height: 40,
            text: 'Import',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _isImporting = true;
      _importWritten = 0;
      _importTotal = rows.length;
    });
    try {
      await ref
          .read(adminBrandProspectsRepositoryProvider)
          .bulkImport(
            rows.cast<Map<String, dynamic>>(),
            onProgress: (written, total) {
              if (!mounted) return;
              setState(() => _importWritten = written);
            },
          );
      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Imported ${rows.length} prospects.');
      _refresh();
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Import failed: $error");
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _pushCategory(
    BrandProspectCategoryCounts row,
    List<StaffAccount> interns,
  ) async {
    final result = await showDialog<_AssignResult>(
      context: context,
      builder: (context) => _AssignDialog(row: row, interns: interns),
    );
    if (result == null) return;

    setState(() => _pushingCategory = row.category);
    try {
      final count = await ref
          .read(adminBrandProspectsRepositoryProvider)
          .assignCategoryToIntern(
            category: row.category,
            internUid: result.intern.uid,
            internEmail: result.intern.email,
            limit: result.limit,
            includeAlreadyAssigned: result.includeAlreadyAssigned,
          );
      if (!mounted) return;
      AppSnackbar.showSuccess(
        context,
        'Pushed $count ${row.category} prospect${count == 1 ? '' : 's'} to '
        '${result.intern.email}.',
      );
      _refresh();
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't push that category: $error");
    } finally {
      if (mounted) setState(() => _pushingCategory = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAsync = ref.watch(brandProspectTotalImportedProvider);
    final breakdownAsync = ref.watch(brandProspectCategoryBreakdownProvider);
    final staffAsync = ref.watch(allStaffAccountsProvider);
    final interns = (staffAsync.value ?? const [])
        .where(
          (s) => s.active && s.permissions['/brand-outreach-leads'] == true,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminTopBar(
          title: 'Brand Prospects',
          subtitle:
              'Bulk-imported brand research — push a category to an intern',
          actions: [
            OutlinedButton.icon(
              onPressed: _isImporting ? null : _import,
              icon: const Icon(Icons.upload_file, size: 16),
              label: Text(_isImporting ? 'Importing…' : 'Import JSON'),
            ),
          ],
        ),
        if (_isImporting)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: _importTotal == 0
                      ? null
                      : _importWritten / _importTotal,
                ),
                const SizedBox(height: 4),
                Text(
                  'Writing $_importWritten of $_importTotal…',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AdminColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                totalAsync.when(
                  loading: () => const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (error, _) => Text(
                    "Couldn't load total: $error",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  data: (total) => Text(
                    '$total prospect${total == 1 ? '' : 's'} imported',
                    style: AppTextStyles.titleLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (interns.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Text(
                      'No active staff account has the Brand Outreach Leads '
                      'permission yet — grant it under Roles before pushing '
                      'a category to anyone.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                breakdownAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Text(
                    "Couldn't load category breakdown: $error",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  data: (rows) => Column(
                    children: [
                      for (final row in rows)
                        _CategoryRow(
                          row: row,
                          isPushing: _pushingCategory == row.category,
                          canPush:
                              interns.isNotEmpty &&
                              (row.unassigned + row.assigned) > 0,
                          onPush: () => _pushCategory(row, interns),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.row,
    required this.isPushing,
    required this.canPush,
    required this.onPush,
  });

  final BrandProspectCategoryCounts row;
  final bool isPushing;
  final bool canPush;
  final VoidCallback onPush;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
            child: Text(
              row.category,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${row.unassigned} unassigned',
              style: AppTextStyles.bodySmall.copyWith(
                color: row.unassigned > 0
                    ? AppColors.primary
                    : AdminColors.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${row.assigned} assigned',
              style: AppTextStyles.bodySmall.copyWith(
                color: AdminColors.textSecondary(context),
              ),
            ),
          ),
          SizedBox(
            width: 140,
            child: OutlinedButton(
              onPressed: canPush && !isPushing ? onPush : null,
              child: isPushing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Push to intern'),
            ),
          ),
        ],
      ),
    );
  }
}

/// What `_AssignDialog` hands back: who to push to, how many, and whether
/// the source pool is just the still-unassigned remainder or the whole
/// category (reassigning ones already pushed elsewhere).
typedef _AssignResult = ({
  StaffAccount intern,
  int limit,
  bool includeAlreadyAssigned,
});

class _AssignDialog extends StatefulWidget {
  const _AssignDialog({required this.row, required this.interns});

  final BrandProspectCategoryCounts row;
  final List<StaffAccount> interns;

  @override
  State<_AssignDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<_AssignDialog> {
  StaffAccount? _chosen;
  bool _includeAlreadyAssigned = false;
  late final TextEditingController _countController;
  String? _countError;

  int get _maxCount => _includeAlreadyAssigned
      ? widget.row.unassigned + widget.row.assigned
      : widget.row.unassigned;

  @override
  void initState() {
    super.initState();
    _chosen = widget.interns.isEmpty ? null : widget.interns.first;
    _countController = TextEditingController(text: '$_maxCount');
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  void _setMode(bool includeAlreadyAssigned) {
    setState(() {
      _includeAlreadyAssigned = includeAlreadyAssigned;
      _countController.text = '$_maxCount';
      _countError = null;
    });
  }

  int? _validatedCount() {
    final value = int.tryParse(_countController.text.trim());
    if (value == null || value < 1 || value > _maxCount) return null;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final hasAlreadyAssigned = widget.row.assigned > 0;

    return AlertDialog(
      title: Text('Push ${widget.row.category} to an intern'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasAlreadyAssigned) ...[
              Text(
                '${widget.row.assigned} prospect'
                '${widget.row.assigned == 1 ? '' : 's'} in this category '
                'have already been pushed out to an intern.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              RadioListTile<bool>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: false,
                groupValue: _includeAlreadyAssigned,
                onChanged: (_) => _setMode(false),
                title: Text(
                  'Only the ${widget.row.unassigned} remaining unassigned',
                ),
              ),
              RadioListTile<bool>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: true,
                groupValue: _includeAlreadyAssigned,
                onChanged: (_) => _setMode(true),
                title: Text(
                  'All ${widget.row.unassigned + widget.row.assigned} '
                  '(reassign the already-pushed ones too)',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            DropdownButtonFormField<StaffAccount>(
              initialValue: _chosen,
              decoration: const InputDecoration(labelText: 'Intern'),
              items: widget.interns
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.email, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _chosen = value),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'How many to push',
                helperText: 'Up to $_maxCount available',
                errorText: _countError,
              ),
              onChanged: (_) => setState(() => _countError = null),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
          width: 100,
          height: 40,
          text: 'Push',
          isEnabled: _chosen != null && _maxCount > 0,
          onPressed: () {
            final count = _validatedCount();
            if (count == null) {
              setState(() => _countError = 'Enter 1–$_maxCount');
              return;
            }
            Navigator.pop(context, (
              intern: _chosen!,
              limit: count,
              includeAlreadyAssigned: _includeAlreadyAssigned,
            ));
          },
        ),
      ],
    );
  }
}
