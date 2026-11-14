import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../shared/models/marketing_task.dart';
import '../providers/marketing_tasks_providers.dart';

const _adminEmail = 'admin@collabsy.online';

const _statusTodo = 'todo';
const _statusInProgress = 'in_progress';
const _statusDone = 'done';

const _columns = [
  (status: _statusTodo, title: 'To Do'),
  (status: _statusInProgress, title: 'In Progress'),
  (status: _statusDone, title: 'Done'),
];

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _fmtDate(DateTime? date) {
  if (date == null) return '';
  return '${_months[date.month - 1]} ${date.day}';
}

/// The whole marketing tracker in one screen — a 3-column Kanban board
/// (To Do / In Progress / Done) over every `marketingTasks` doc. Every
/// signed-in account (admin or any active staff — see `marketing_router`)
/// sees the same board; who can act on a given card is enforced by
/// `firestore.rules`, not hidden client-side, but the UI only shows the
/// controls a given viewer could actually use: admin gets "New task" plus
/// edit/delete on every card, everyone else gets an "Update" action only
/// on cards assigned to them.
class MarketingBoardScreen extends ConsumerWidget {
  const MarketingBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authRepositoryProvider).currentUser;
    final isAdmin = currentUser?.email == _adminEmail;
    final tasksAsync = ref.watch(allMarketingTasksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              isAdmin: isAdmin,
              onNewTask: () => showDialog<void>(
                context: context,
                builder: (context) => const _TaskFormDialog(),
              ),
              onSignOut: () => ref.read(authRepositoryProvider).signOut(),
            ),
            Expanded(
              child: tasksAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text('Failed to load: $error')),
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return const EmptyState(
                      icon: Icons.task_alt_outlined,
                      title: 'No tasks yet',
                      subtitle: 'Admin can add the first one above.',
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final column in _columns) ...[
                          Expanded(
                            child: _TaskColumn(
                              title: column.title,
                              tasks: tasks
                                  .where((t) => t.status == column.status)
                                  .toList(),
                              currentUserId: currentUser?.uid,
                              isAdmin: isAdmin,
                            ),
                          ),
                          if (column != _columns.last)
                            const SizedBox(width: AppSpacing.md),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isAdmin,
    required this.onNewTask,
    required this.onSignOut,
  });

  final bool isAdmin;
  final VoidCallback onNewTask;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text('Marketing Tracker', style: AppTextStyles.titleLarge),
          const Spacer(),
          if (isAdmin) ...[
            PrimaryButton(
              width: 140,
              height: 40,
              text: 'New task',
              icon: Icons.add,
              onPressed: onNewTask,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            tooltip: 'Sign out',
            onPressed: onSignOut,
          ),
        ],
      ),
    );
  }
}

class _TaskColumn extends StatelessWidget {
  const _TaskColumn({
    required this.title,
    required this.tasks,
    required this.currentUserId,
    required this.isAdmin,
  });

  final String title;
  final List<MarketingTask> tasks;
  final String? currentUserId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              '$title (${tasks.length})',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: tasks.isEmpty
                ? const SizedBox.shrink()
                : ListView.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (context, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) => _TaskCard(
                      task: tasks[index],
                      canAct:
                          isAdmin || tasks[index].assigneeId == currentUserId,
                      isAdmin: isAdmin,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.canAct,
    required this.isAdmin,
  });

  final MarketingTask task;
  final bool canAct;
  final bool isAdmin;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"${task.title}" will be gone for good.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(marketingTasksRepositoryProvider).delete(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final overdue =
        task.dueDate != null &&
        task.status != _statusDone &&
        task.dueDate!.isBefore(DateTime.now());

    return Consumer(
      builder: (context, ref, _) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.sm + 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isAdmin) ...[
                    InkWell(
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (context) => _TaskFormDialog(existing: task),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _confirmDelete(context, ref),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      task.assigneeEmail,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (task.dueDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: overdue
                            ? AppColors.errorLight
                            : AppColors.background,
                        border: overdue
                            ? null
                            : Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        _fmtDate(task.dueDate),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: overdue
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              if (task.targetCount != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: LinearProgressIndicator(
                          value: (task.currentCount ?? 0) / task.targetCount!,
                          minHeight: 6,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${task.currentCount ?? 0}/${task.targetCount}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              if (canAct) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => _UpdateProgressDialog(task: task),
                    ),
                    child: const Text('Update'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// The assignee's (or admin's) own quick action — move the status along
/// and/or bump the running count. Matches `firestore.rules`' exact
/// allowed shape for a non-admin's update.
class _UpdateProgressDialog extends ConsumerStatefulWidget {
  const _UpdateProgressDialog({required this.task});

  final MarketingTask task;

  @override
  ConsumerState<_UpdateProgressDialog> createState() =>
      _UpdateProgressDialogState();
}

class _UpdateProgressDialogState
    extends ConsumerState<_UpdateProgressDialog> {
  late String _status;
  late final TextEditingController _countController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.task.status;
    _countController = TextEditingController(
      text: '${widget.task.currentCount ?? 0}',
    );
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final target = widget.task.targetCount;
    int? currentCount;
    if (target != null) {
      currentCount = int.tryParse(_countController.text.trim());
      if (currentCount == null || currentCount < 0) {
        AppSnackbar.showError(context, 'Enter a valid number.');
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(marketingTasksRepositoryProvider)
          .updateProgress(
            taskId: widget.task.id,
            status: _status,
            currentCount: currentCount,
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppSnackbar.showError(context, "Couldn't save your update.");
      return;
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task.title),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: _statusTodo, child: Text('To Do')),
                DropdownMenuItem(
                  value: _statusInProgress,
                  child: Text('In Progress'),
                ),
                DropdownMenuItem(value: _statusDone, child: Text('Done')),
              ],
              onChanged: _isSaving
                  ? null
                  : (value) => setState(() => _status = value!),
            ),
            if (widget.task.targetCount != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _countController,
                label: 'Sent so far (of ${widget.task.targetCount})',
                keyboardType: TextInputType.number,
                enabled: !_isSaving,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
          width: 100,
          height: 40,
          text: 'Save',
          isLoading: _isSaving,
          onPressed: _isSaving ? null : _save,
        ),
      ],
    );
  }
}

/// Admin-only — create (no [existing]) or edit (with [existing]) a task's
/// title/description/assignee/target/due date.
class _TaskFormDialog extends ConsumerStatefulWidget {
  const _TaskFormDialog({this.existing});

  final MarketingTask? existing;

  @override
  ConsumerState<_TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<_TaskFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _targetController;
  String? _assigneeId;
  String? _assigneeEmail;
  DateTime? _dueDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _targetController = TextEditingController(
      text: existing?.targetCount?.toString() ?? '',
    );
    _assigneeId = existing?.assigneeId;
    _assigneeEmail = existing?.assigneeEmail;
    _dueDate = existing?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _assigneeId == null) {
      AppSnackbar.showError(context, 'Enter a title and pick an assignee.');
      return;
    }
    final targetText = _targetController.text.trim();
    final target = targetText.isEmpty ? null : int.tryParse(targetText);
    if (targetText.isNotEmpty && (target == null || target <= 0)) {
      AppSnackbar.showError(context, 'Target must be a positive number.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repository = ref.read(marketingTasksRepositoryProvider);
      if (widget.existing != null) {
        await repository.edit(
          taskId: widget.existing!.id,
          title: title,
          description: _descriptionController.text.trim(),
          assigneeId: _assigneeId!,
          assigneeEmail: _assigneeEmail!,
          targetCount: target,
          dueDate: _dueDate,
        );
      } else {
        final createdBy =
            ref.read(authRepositoryProvider).currentUser?.email ?? '';
        await repository.create(
          title: title,
          description: _descriptionController.text.trim(),
          assigneeId: _assigneeId!,
          assigneeEmail: _assigneeEmail!,
          createdBy: createdBy,
          targetCount: target,
          dueDate: _dueDate,
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppSnackbar.showError(context, "Couldn't save the task.");
      return;
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(assignableStaffProvider);

    return AlertDialog(
      title: Text(widget.existing == null ? 'New task' : 'Edit task'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _titleController,
              label: 'Title',
              enabled: !_isSaving,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            staffAsync.when(
              data: (staff) => DropdownButtonFormField<String>(
                initialValue: staff.any((s) => s.uid == _assigneeId)
                    ? _assigneeId
                    : null,
                decoration: const InputDecoration(labelText: 'Assignee'),
                items: [
                  for (final s in staff)
                    DropdownMenuItem(value: s.uid, child: Text(s.email)),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        final match = staff.firstWhere((s) => s.uid == value);
                        setState(() {
                          _assigneeId = match.uid;
                          _assigneeEmail = match.email;
                        });
                      },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text('Could not load staff accounts.'),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _targetController,
              label: 'Daily target (optional, e.g. 200)',
              keyboardType: TextInputType.number,
              enabled: !_isSaving,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? 'No due date'
                        : 'Due ${_fmtDate(_dueDate)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _isSaving ? null : _pickDueDate,
                  child: const Text('Pick date'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
          width: 100,
          height: 40,
          text: 'Save',
          isLoading: _isSaving,
          onPressed: _isSaving ? null : _save,
        ),
      ],
    );
  }
}
