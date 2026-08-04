import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/firestore_converters.dart';
import 'notification_type.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// Matches a document in the `notifications` Firestore collection.
/// [referenceType] is `'campaign'` or `'chat'` — tells the feed which route
/// to push on tap using [referenceId]; both are null for notifications with
/// nowhere specific to go.
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    String? referenceType,
    String? referenceId,
    @Default(false) bool read,
    @NullableTimestampConverter() DateTime? createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
