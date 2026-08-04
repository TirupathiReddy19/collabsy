import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/firestore_converters.dart';
import 'chat_status.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

/// Matches a document in the `chats` Firestore collection.
///
/// One thread ever exists per brand+creator pair — a chat is a property of
/// the relationship between the two profiles, not of any particular
/// campaign. [status] starts as [ChatStatus.request] for creator-initiated
/// or Discovery-initiated contact, or [ChatStatus.active] immediately when
/// a brand messages an applicant directly, or whenever a brand accepts an
/// application from that creator. `lastReadAt` per participant drives the
/// unread indicator (not a per-message read flag).
@freezed
abstract class Chat with _$Chat {
  const factory Chat({
    required String id,
    required String creatorId,
    required String creatorName,
    required String brandId,
    required String brandName,
    @Default(ChatStatus.request) ChatStatus status,
    String? lastMessage,
    @NullableTimestampConverter() DateTime? lastMessageAt,
    @NullableTimestampConverter() DateTime? creatorLastReadAt,
    @NullableTimestampConverter() DateTime? brandLastReadAt,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
}
