import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/utils/firestore_converters.dart';

part 'announcement.freezed.dart';
part 'announcement.g.dart';

/// Matches a document in the `announcements` collection — one doc per
/// broadcast, shared by everyone in [audience] (not fanned out into a
/// per-recipient copy). Modeled after `SupportChat`'s "admin is the other
/// side" pattern rather than the `chats` collection, which requires two
/// real participant ids and has no concept of a system sender.
@freezed
abstract class Announcement with _$Announcement {
  const factory Announcement({
    required String id,
    required String title,
    required String body,
    required String audience,
    @NullableTimestampConverter() DateTime? createdAt,
    String? createdBy,
    // Narrows `audience` down to a subset of Creators. Missing on every
    // broadcast sent before this existed — defaults to 'all' so historical
    // rows keep behaving exactly as "every Creator in `audience`" did.
    @Default('all') String targetType,
    List<String>? targetCategories,
    int? targetMinFollowers,
    int? targetMaxFollowers,
    String? targetCreatorId,
    String? targetCreatorName,
    // Brand-audience equivalents of the Creator-only fields above —
    // `targetType`/`targetCategories` are reused as-is (same shape,
    // matched against `brandProfiles` instead of `creatorProfiles` when
    // `audience == 'brand'`).
    String? targetBrandId,
    String? targetBrandName,
    String? targetCompanySize,
  }) = _Announcement;

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);
}
