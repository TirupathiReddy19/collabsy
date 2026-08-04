import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/firestore_converters.dart';

part 'instagram_account.freezed.dart';
part 'instagram_account.g.dart';

enum InstagramConnectionStatus {
  connected,
  expired,
  revoked,
  disconnected;

  static InstagramConnectionStatus fromDbValue(String? value) {
    return InstagramConnectionStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => InstagramConnectionStatus.disconnected,
    );
  }

  String toDbValue() => name;
}

/// Matches a document in the `instagram_accounts` collection — the account
/// summary + profile snapshot the client is allowed to read. The actual
/// access/refresh tokens never live on this document; they're kept in a
/// `instagram_accounts/{userId}/private/tokens` doc that only Cloud
/// Functions (via the Admin SDK) can read, per `firestore.rules`.
@freezed
abstract class InstagramAccount with _$InstagramAccount {
  const factory InstagramAccount({
    required String id,
    @Default(InstagramConnectionStatus.disconnected)
    InstagramConnectionStatus status,
    String? instagramUserId,
    String? username,
    String? name,
    String? profilePictureUrl,
    String? biography,
    String? website,
    @Default(0) int followersCount,
    @Default(0) int followsCount,
    @Default(0) int mediaCount,
    @NullableTimestampConverter() DateTime? connectedAt,
    @NullableTimestampConverter() DateTime? lastSyncedAt,
  }) = _InstagramAccount;

  factory InstagramAccount.fromJson(Map<String, dynamic> json) =>
      _$InstagramAccountFromJson(json);
}
