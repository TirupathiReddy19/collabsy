import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/firestore_converters.dart';
import '../../../shared/models/user_role.dart';
import 'support_chat_status.dart';
import 'support_message.dart';
import 'support_ticket_category.dart';

part 'support_chat.freezed.dart';
part 'support_chat.g.dart';

/// Matches a document in the `supportChats` collection — one doc per
/// *ticket*, not per user: a user can have many over time (a resolved
/// ticket stays as history; contacting support again starts a new one).
/// `id` is an auto-generated ticket id, `userId` is who it belongs to.
/// Entirely separate from the `chats` collection used for
/// Creator<->Brand messaging. The signed-in admin is the other side of
/// every thread; there's no per-agent identity yet (see the
/// `AuditLogAction`-style single-admin model used elsewhere).
@freezed
abstract class SupportChat with _$SupportChat {
  const factory SupportChat({
    required String id,
    required String userId,
    required String userName,
    required UserRole userRole,
    @Default(SupportChatStatus.open) SupportChatStatus status,
    @NullableTimestampConverter() DateTime? createdAt,
    String? lastMessage,
    @NullableTimestampConverter() DateTime? lastMessageAt,
    // Who sent the most recent message — used by the admin list to flag a
    // ticket as overdue (open, and the user is the one waiting on a reply).
    SupportSenderRole? lastMessageSenderRole,
    @NullableTimestampConverter() DateTime? userLastReadAt,
    @NullableTimestampConverter() DateTime? supportLastReadAt,
    // Admin/staff-only triage fields — never writable by the ticket's own
    // user (see firestore.rules' supportChats/{userId} update rule).
    SupportTicketCategory? category,
    String? internalNotes,
    @NullableTimestampConverter() DateTime? internalNotesUpdatedAt,
    String? internalNotesUpdatedBy,
  }) = _SupportChat;

  factory SupportChat.fromJson(Map<String, dynamic> json) =>
      _$SupportChatFromJson(json);
}
