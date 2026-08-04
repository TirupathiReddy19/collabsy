import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/firestore_converters.dart';
import '../../../shared/models/user_role.dart';

part 'block.freezed.dart';
part 'block.g.dart';

/// Matches a document in the `blocks` collection — doc id is always
/// `{blockerId}_{blockedId}` (see `BlockingRepository._docId`), so "does A
/// block B" is a plain doc-existence check on both the client and in
/// `firestore.rules`' `isBlocked()`. Unblocking is just deleting this doc.
@freezed
abstract class Block with _$Block {
  const factory Block({
    required String id,
    required String blockerId,
    required UserRole blockerRole,
    required String blockedId,
    required UserRole blockedRole,
    @NullableTimestampConverter() DateTime? createdAt,
  }) = _Block;

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);
}
