import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/firestore_converters.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// Matches a document in a `chats/{chatId}/messages` subcollection.
///
/// [campaignId] is set only for an auto-sent "campaign link" message (e.g.
/// when a creator messages a brand from campaign detail) — the chat screen
/// renders those as a tappable card showing live campaign details instead
/// of a plain text bubble.
@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String senderId,
    required String text,
    String? campaignId,
    @NullableTimestampConverter() DateTime? sentAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
