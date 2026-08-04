import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../features/support/models/support_chat_status.dart';
import '../../features/support/models/support_message.dart';
import '../../features/support/models/support_ticket_category.dart';
import '../../features/support/providers/support_chat_providers.dart';
import '../models/audit_log.dart';
import '../models/canned_reply.dart';
import '../providers/admin_audit_log_providers.dart';
import '../providers/admin_auth_providers.dart';
import '../widgets/admin_top_bar.dart';
import '../theme/admin_colors.dart';

/// The admin's side of one support ticket — same underlying collection as
/// [AdminSupportScreen] lists, just scoped to one ticket. A user may have
/// several tickets over time (see the mobile-side ticket history screen);
/// this only ever shows one at a time.
class AdminSupportChatDetailScreen extends ConsumerStatefulWidget {
  const AdminSupportChatDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<AdminSupportChatDetailScreen> createState() =>
      _AdminSupportChatDetailScreenState();
}

class _AdminSupportChatDetailScreenState
    extends ConsumerState<AdminSupportChatDetailScreen> {
  final _textController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSending = false;
  bool _isUpdatingStatus = false;
  bool _isSavingNotes = false;
  bool _notesExpanded = false;
  bool _notesLoaded = false;

  @override
  void initState() {
    super.initState();
    // Clears the unread indicator on the Support Tickets list — a no-op
    // Firestore write, so it's safe to fire on every open regardless of
    // whether this ticket was actually unread.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(supportChatRepositoryProvider)
          .markRead(ticketId: widget.ticketId, asAdmin: true);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// The ticket owner's display name for audit-log entries, falling back to
  /// the ticket id if the chat doc hasn't loaded (shouldn't happen in
  /// practice — this is only ever called after a successful send/status
  /// -change against an already-open ticket).
  String _targetName() =>
      ref.read(supportTicketProvider(widget.ticketId)).value?.userName ??
      widget.ticketId;

  String _actorEmail() => ref.read(currentAdminEmailProvider) ?? adminEmail;

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    final userId = ref
        .read(supportTicketProvider(widget.ticketId))
        .value
        ?.userId;
    if (userId == null) return;
    _textController.clear();
    setState(() => _isSending = true);
    try {
      await ref
          .read(supportChatRepositoryProvider)
          .sendMessage(
            ticketId: widget.ticketId,
            userId: userId,
            senderRole: SupportSenderRole.support,
            text: text,
          );
      await ref
          .read(adminAuditLogRepositoryProvider)
          .log(
            actorEmail: _actorEmail(),
            action: AuditLogAction.supportReplySent,
            targetId: widget.ticketId,
            targetName: _targetName(),
          );
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't send the reply.");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _setStatus(SupportChatStatus status) async {
    setState(() => _isUpdatingStatus = true);
    try {
      await ref
          .read(supportChatRepositoryProvider)
          .setStatus(ticketId: widget.ticketId, status: status);
      await ref
          .read(adminAuditLogRepositoryProvider)
          .log(
            actorEmail: _actorEmail(),
            action: status == SupportChatStatus.resolved
                ? AuditLogAction.supportTicketResolved
                : AuditLogAction.supportTicketReopened,
            targetId: widget.ticketId,
            targetName: _targetName(),
          );
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't update the ticket status.");
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _setCategory(SupportTicketCategory category) async {
    try {
      await ref
          .read(supportChatRepositoryProvider)
          .setCategory(ticketId: widget.ticketId, category: category);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't update the category.");
    }
  }

  Future<void> _saveNotes() async {
    setState(() => _isSavingNotes = true);
    try {
      await ref
          .read(supportChatRepositoryProvider)
          .setInternalNotes(
            ticketId: widget.ticketId,
            notes: _notesController.text.trim(),
            updatedByEmail: _actorEmail(),
          );
      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Note saved.');
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't save the note.");
    } finally {
      if (mounted) setState(() => _isSavingNotes = false);
    }
  }

  Future<void> _showCannedReplies() async {
    final reply = await showModalBottomSheet<CannedReply>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            for (final reply in cannedReplies)
              ListTile(
                title: Text(reply.label),
                subtitle: Text(
                  reply.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Navigator.of(context).pop(reply),
              ),
          ],
        ),
      ),
    );
    if (reply == null) return;
    _textController.text = reply.text;
    _textController.selection = TextSelection.collapsed(
      offset: _textController.text.length,
    );
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/support');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(supportTicketProvider(widget.ticketId));
    final messagesAsync = ref.watch(
      supportTicketMessagesProvider(widget.ticketId),
    );
    final chat = chatAsync.value;

    if (!_notesLoaded && chat != null) {
      _notesLoaded = true;
      _notesController.text = chat.internalNotes ?? '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gated on `chatAsync.when()` rather than reading `.value` directly
        // so the name/role/status-button only ever render together once the
        // thread doc has actually loaded, instead of silently omitting them
        // on any build where the stream hasn't delivered a value yet.
        chatAsync.when(
          loading: () => AdminTopBar(
            title: 'Support Ticket',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _back(context),
            ),
          ),
          error: (error, _) => AdminTopBar(
            title: 'Support Ticket',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _back(context),
            ),
          ),
          data: (chat) => AdminTopBar(
            title: chat?.userName ?? 'Support Ticket',
            subtitle: chat == null
                ? null
                : '${chat.userRole.label} · Ticket #${widget.ticketId}',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _back(context),
            ),
            actions: [
              if (chat != null)
                OutlinedButton.icon(
                  onPressed: _isUpdatingStatus
                      ? null
                      : () => _setStatus(
                          chat.status == SupportChatStatus.open
                              ? SupportChatStatus.resolved
                              : SupportChatStatus.open,
                        ),
                  icon: Icon(
                    chat.status == SupportChatStatus.open
                        ? Icons.check_circle_outline
                        : Icons.replay,
                    size: 18,
                  ),
                  label: Text(
                    chat.status == SupportChatStatus.open
                        ? 'Mark resolved'
                        : 'Reopen',
                  ),
                ),
            ],
          ),
        ),
        if (chat != null) ...[
          StaggeredFadeIn(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Row(
                children: [
                  Text(
                    'Category',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AdminColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<SupportTicketCategory>(
                    value: chat.category,
                    hint: const Text('Uncategorized'),
                    underline: const SizedBox.shrink(),
                    items: [
                      for (final category in SupportTicketCategory.values)
                        DropdownMenuItem(
                          value: category,
                          child: Text(category.label),
                        ),
                    ],
                    onChanged: (category) =>
                        category == null ? null : _setCategory(category),
                  ),
                ],
              ),
            ),
          ),
          StaggeredFadeIn(
            delay: const Duration(milliseconds: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    'Internal notes (staff only)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AdminColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  initiallyExpanded: _notesExpanded,
                  onExpansionChanged: (expanded) =>
                      setState(() => _notesExpanded = expanded),
                  childrenPadding: const EdgeInsets.only(bottom: 12),
                  children: [
                    AppTextField(
                      controller: _notesController,
                      hintText: 'Not visible to the user...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: _isSavingNotes ? null : _saveNotes,
                        child: _isSavingNotes
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save note'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        Expanded(
          child: messagesAsync.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, _) => Center(child: Text('Failed to load: $error')),
            data: (messages) {
              if (messages.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AdminColors.textSecondary(context),
                    ),
                  ),
                );
              }
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.md,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  final mine = message.senderRole == SupportSenderRole.support;
                  return _Bubble(
                    text: message.text,
                    imageUrl: message.imageUrl,
                    mine: mine,
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.bolt_outlined,
                  color: AdminColors.textSecondary(context),
                ),
                tooltip: 'Canned replies',
                onPressed: _showCannedReplies,
              ),
              Expanded(
                child: AppTextField(
                  controller: _textController,
                  hintText: 'Reply...',
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send, color: AppColors.primary),
                onPressed: _isSending ? null : _send,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, this.imageUrl, required this.mine});

  final String text;
  final String? imageUrl;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final textColor = mine ? AppColors.white : AdminColors.textPrimary(context);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : AdminColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: mine ? null : Border.all(color: AdminColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            if (text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  text,
                  style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
