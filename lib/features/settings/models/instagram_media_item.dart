import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/firestore_converters.dart';

part 'instagram_media_item.freezed.dart';
part 'instagram_media_item.g.dart';

/// Matches a document in the `instagram_media` collection — one per IG
/// media item, synced server-side after a successful connect/refresh.
/// `id` is the Instagram media ID itself (not an auto-generated Firestore
/// ID), so re-syncing is a natural upsert rather than creating duplicates.
@freezed
abstract class InstagramMediaItem with _$InstagramMediaItem {
  const factory InstagramMediaItem({
    required String id,
    required String userId,
    String? mediaUrl,
    String? mediaType,
    String? thumbnailUrl,
    String? permalink,
    String? caption,
    @NullableTimestampConverter() DateTime? timestamp,
  }) = _InstagramMediaItem;

  factory InstagramMediaItem.fromJson(Map<String, dynamic> json) =>
      _$InstagramMediaItemFromJson(json);
}
