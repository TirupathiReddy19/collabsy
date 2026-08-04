import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/models/user_role.dart';
import '../models/report_reason.dart';
import '../providers/blocking_providers.dart';

/// Bottom sheet for reporting another user — reused from the chat
/// conversation screen and both public profile screens. Same
/// `static Future<T?> show(...)` + `showModalBottomSheet` convention as
/// `ChangeEmailSheet`/`ChangePhoneSheet`.
class ReportUserSheet extends ConsumerStatefulWidget {
  const ReportUserSheet({
    super.key,
    required this.reportedId,
    required this.reportedRole,
    this.reportedName,
    this.chatId,
  });

  final String reportedId;
  final UserRole reportedRole;
  final String? reportedName;
  final String? chatId;

  static Future<bool?> show(
    BuildContext context, {
    required String reportedId,
    required UserRole reportedRole,
    String? reportedName,
    String? chatId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ReportUserSheet(
        reportedId: reportedId,
        reportedRole: reportedRole,
        reportedName: reportedName,
        chatId: chatId,
      ),
    );
  }

  @override
  ConsumerState<ReportUserSheet> createState() => _ReportUserSheetState();
}

class _ReportUserSheetState extends ConsumerState<ReportUserSheet> {
  ReportReason? _reason;
  final _detailsController = TextEditingController();
  bool _alsoBlock = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reason;
    if (reason == null) return;

    final details = _detailsController.text.trim();
    await ref
        .read(blockingControllerProvider.notifier)
        .report(
          reportedId: widget.reportedId,
          reportedRole: widget.reportedRole,
          reportedName: widget.reportedName,
          reason: reason,
          details: details.isEmpty ? null : details,
          chatId: widget.chatId,
        );
    if (!mounted) return;
    if (ref.read(blockingControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't submit the report.");
      return;
    }

    if (_alsoBlock) {
      await ref
          .read(blockingControllerProvider.notifier)
          .block(
            blockedId: widget.reportedId,
            blockedRole: widget.reportedRole,
          );
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
    AppSnackbar.showSuccess(context, 'Report submitted.');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(blockingControllerProvider).isLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenHorizontal,
        right: AppSpacing.screenHorizontal,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report ${widget.reportedName ?? 'this user'}',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReportReason.values.map((reason) {
              final selected = _reason == reason;
              return ChoiceChip(
                label: Text(reason.label),
                selected: selected,
                onSelected: isLoading
                    ? null
                    : (_) => setState(() => _reason = reason),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _detailsController,
            label: 'Additional details (optional)',
            maxLines: 3,
            enabled: !isLoading,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _alsoBlock,
            onChanged: isLoading
                ? null
                : (value) => setState(() => _alsoBlock = value ?? false),
            title: const Text('Also block this user'),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            text: 'Submit report',
            isLoading: isLoading,
            onPressed: (_reason == null || isLoading) ? null : _submit,
          ),
        ],
      ),
    );
  }
}
