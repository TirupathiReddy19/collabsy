import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/firestore_converters.dart';

part 'support_message.freezed.dart';
part 'support_message.g.dart';

enum SupportSenderRole {
  user,
  support;

  static SupportSenderRole fromDbValue(String? value) =>
      value == 'support' ? SupportSenderRole.support : SupportSenderRole.user;

  String toDbValue() => name;
}

/// Matches a document in a `supportChats/{userId}/messages` subcollection.
@freezed
abstract class SupportMessage with _$SupportMessage {
  const factory SupportMessage({
    required String id,
    required SupportSenderRole senderRole,
    required String text,
    String? imageUrl,
    @NullableTimestampConverter() DateTime? sentAt,
  }) = _SupportMessage;

  factory SupportMessage.fromJson(Map<String, dynamic> json) =>
      _$SupportMessageFromJson(json);
}
