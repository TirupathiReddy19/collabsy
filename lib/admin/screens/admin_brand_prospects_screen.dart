import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/primary_button.dart';
import '../../shared/models/brand_prospect.dart';
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

  void _viewCategory(BrandProspectCategoryCounts row) {
    showDialog<void>(
      context: context,
      builder: (context) => _ProspectsBrowserDialog(row: row),
    );
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
                          onView: () => _viewCategory(row),
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
    required this.onView,
  });

  final BrandProspectCategoryCounts row;
  final bool isPushing;
  final bool canPush;
  final VoidCallback onPush;
  final VoidCallback onView;

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
            width: 90,
            child: OutlinedButton(
              onPressed: (row.unassigned + row.assigned) > 0 ? onView : null,
              child: const Text('View'),
            ),
          ),
          const SizedBox(width: 8),
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

enum _StatusFilter {
  all('All'),
  unassigned('Unassigned'),
  assigned('Assigned');

  const _StatusFilter(this.label);
  final String label;
}

/// Lets admin page through the raw `brandProspects` docs in one category —
/// brand name, website, Instagram, LinkedIn, and email(s) — so they can
/// actually see what's in the pool (and verify contact details) before
/// deciding what to push, rather than only ever seeing aggregate counts.
class _ProspectsBrowserDialog extends ConsumerStatefulWidget {
  const _ProspectsBrowserDialog({required this.row});

  final BrandProspectCategoryCounts row;

  @override
  ConsumerState<_ProspectsBrowserDialog> createState() =>
      _ProspectsBrowserDialogState();
}

class _ProspectsBrowserDialogState
    extends ConsumerState<_ProspectsBrowserDialog> {
  _StatusFilter _filter = _StatusFilter.all;
  final List<BrandProspect> _prospects = [];
  DocumentSnapshot<Map<String, dynamic>>? _cursor;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  String? get _statusValue => switch (_filter) {
    _StatusFilter.all => null,
    _StatusFilter.unassigned => 'unassigned',
    _StatusFilter.assigned => 'assigned',
  };

  Future<void> _reload() async {
    setState(() {
      _prospects.clear();
      _cursor = null;
      _hasMore = true;
      _error = null;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    try {
      final page = await ref
          .read(adminBrandProspectsRepositoryProvider)
          .listByCategory(
            category: widget.row.category,
            status: _statusValue,
            startAfter: _cursor,
          );
      if (!mounted) return;
      setState(() {
        _prospects.addAll(page.prospects);
        _cursor = page.cursor;
        _hasMore = page.cursor != null && page.prospects.isNotEmpty;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.row.category} prospects'),
      content: SizedBox(
        width: 540,
        height: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final filter in _StatusFilter.values)
                  ChoiceChip(
                    label: Text(filter.label),
                    selected: _filter == filter,
                    onSelected: (_) {
                      setState(() => _filter = filter);
                      _reload();
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: _error != null
                  ? Text(
                      "Couldn't load prospects: $_error",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    )
                  : _prospects.isEmpty && !_isLoading
                  ? Center(
                      child: Text(
                        'No prospects match this filter.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AdminColors.textSecondary(context),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _prospects.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _prospects.length) {
                          if (!_hasMore) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : OutlinedButton(
                                      onPressed: _loadMore,
                                      child: const Text('Load more'),
                                    ),
                            ),
                          );
                        }
                        return _ProspectDetailCard(
                          prospect: _prospects[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ProspectDetailCard extends StatelessWidget {
  const _ProspectDetailCard({required this.prospect});

  final BrandProspect prospect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm + 4),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AdminColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  prospect.brandName.isEmpty ? '(no name)' : prospect.brandName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: prospect.status == 'assigned'
                      ? AppColors.primaryLight
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  prospect.status == 'assigned'
                      ? 'Assigned · ${prospect.assignedToEmail ?? '—'}'
                      : 'Unassigned',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: prospect.status == 'assigned'
                        ? AppColors.primary
                        : AdminColors.textSecondary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _DetailLine(label: 'Website', value: prospect.website),
          _DetailLine(
            label: 'Email${prospect.emails.length == 1 ? '' : 's'}',
            value: prospect.emails.isEmpty ? null : prospect.emails.join(', '),
          ),
          _DetailLine(label: 'Instagram', value: prospect.instagramUrl),
          _DetailLine(label: 'LinkedIn', value: prospect.linkedinUrl),
        ],
      ),
    );
  }
}

/// One copyable `label: value` line — `—` and no copy action when [value]
/// is null/empty, so missing contact details read as missing rather than
/// a broken button.
class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String? value;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: value!));
    if (!context.mounted) return;
    AppSnackbar.showSuccess(context, '$label copied.');
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AdminColors.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              hasValue ? value! : '—',
              style: AppTextStyles.bodySmall.copyWith(
                color: hasValue
                    ? AdminColors.textPrimary(context)
                    : AdminColors.textSecondary(context),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasValue)
            InkWell(
              onTap: () => _copy(context),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.copy, size: 13, color: AppColors.textHint),
              ),
            ),
        ],
      ),
    );
  }
}
