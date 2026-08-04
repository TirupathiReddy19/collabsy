import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/avatar_picker.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/verified_badge.dart';
import '../models/support_chat_status.dart';
import '../models/support_message.dart';
import '../providers/support_chat_providers.dart';

/// The user-facing side of one support ticket — reached via the Help
/// screen's "Contact support" button (which resolves which ticket to open;
/// see [SupportHelpScreen]) or a support-reply notification. Deliberately
/// its own screen/collection, never mixed with the Creator<->Brand `chats`
/// messaging feature.
class SupportChatScreen extends ConsumerStatefulWidget {
  const SupportChatScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final _textController = TextEditingController();
  File? _pendingImage;
  bool _isReopening = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await pickAvatarImage(context);
    if (!mounted || image == null) return;
    setState(() => _pendingImage = image);
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _pendingImage == null) return;
    final image = _pendingImage;
    _textController.clear();
    setState(() => _pendingImage = null);
    await ref
        .read(supportChatControllerProvider.notifier)
        .sendMessage(widget.ticketId, text, image: image);
  }

  Future<void> _reopen() async {
    setState(() => _isReopening = true);
    try {
      await ref
          .read(supportChatRepositoryProvider)
          .setStatus(ticketId: widget.ticketId, status: SupportChatStatus.open);
    } finally {
      if (mounted) setState(() => _isReopening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      supportTicketMessagesProvider(widget.ticketId),
    );
    final chat = ref.watch(supportTicketProvider(widget.ticketId)).value;
    final resolved = chat?.status == SupportChatStatus.resolved;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Support'),
            const SizedBox(width: 6),
            const VerifiedBadge(
              variant: VerifiedBadgeVariant.support,
              size: 18,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (chat != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.sm,
                ),
                color: AppColors.primaryLight,
                child: Text(
                  resolved
                      ? 'Ticket #${chat.id} · Resolved'
                      : 'Ticket #${chat.id} · Open · Our support team '
                            'typically responds within 15–30 minutes.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppSpacing.screenHorizontal,
                        ),
                        child: Text(
                          "Have a question or ran into an issue? Send us a "
                          "message and we'll get back to you here.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final mine = message.senderRole == SupportSenderRole.user;
                      return _SupportBubble(
                        text: message.text,
                        imageUrl: message.imageUrl,
                        mine: mine,
                      );
                    },
                  );
                },
                loading: () => const Center(child: LoadingIndicator()),
                error: (error, stackTrace) =>
                    const Center(child: Text("Couldn't load messages.")),
              ),
            ),
            // A resolved ticket hides the reply box entirely — reopening is
            // the explicit action that resumes the conversation, rather
            // than silently accepting new messages on a closed ticket.
            if (resolved)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isReopening ? null : _reopen,
                    icon: _isReopening
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.replay),
                    label: const Text('Reopen this ticket'),
                  ),
                ),
              )
            else ...[
              if (_pendingImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _pendingImage!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: GestureDetector(
                            onTap: () => setState(() => _pendingImage = null),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: AppColors.textPrimary,
                              child: Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: _pickImage,
                    ),
                    Expanded(
                      child: AppTextField(
                        controller: _textController,
                        hintText: 'Message support...',
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppColors.primary),
                      onPressed: _send,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SupportBubble extends StatelessWidget {
  const _SupportBubble({required this.text, this.imageUrl, required this.mine});

  final String text;
  final String? imageUrl;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final textColor = mine ? AppColors.white : AppColors.textPrimary;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: mine ? null : Border.all(color: AppColors.border),
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
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const SizedBox(
                          width: 160,
                          height: 160,
                          child: Center(child: LoadingIndicator()),
                        ),
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
