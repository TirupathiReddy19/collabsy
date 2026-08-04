// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_broadcast_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every broadcast ever sent, newest first — the Admin Broadcast screen's
/// "past broadcasts" list.

@ProviderFor(allAnnouncements)
final allAnnouncementsProvider = AllAnnouncementsProvider._();

/// Every broadcast ever sent, newest first — the Admin Broadcast screen's
/// "past broadcasts" list.

final class AllAnnouncementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Announcement>>,
          List<Announcement>,
          Stream<List<Announcement>>
        >
    with
        $FutureModifier<List<Announcement>>,
        $StreamProvider<List<Announcement>> {
  /// Every broadcast ever sent, newest first — the Admin Broadcast screen's
  /// "past broadcasts" list.
  AllAnnouncementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allAnnouncementsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allAnnouncementsHash();

  @$internal
  @override
  $StreamProviderElement<List<Announcement>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Announcement>> create(Ref ref) {
    return allAnnouncements(ref);
  }
}

String _$allAnnouncementsHash() => r'8a419d552206f40b1d51c56a49d72a07d1d989fb';

/// How many people have seen a given broadcast — anyone who opened the
/// Announcements screen at or after it was sent. [sentAtMillis] (rather
/// than the `DateTime` itself) keeps this family provider's cache key a
/// plain comparable value.

@ProviderFor(announcementSeenCount)
final announcementSeenCountProvider = AnnouncementSeenCountFamily._();

/// How many people have seen a given broadcast — anyone who opened the
/// Announcements screen at or after it was sent. [sentAtMillis] (rather
/// than the `DateTime` itself) keeps this family provider's cache key a
/// plain comparable value.

final class AnnouncementSeenCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// How many people have seen a given broadcast — anyone who opened the
  /// Announcements screen at or after it was sent. [sentAtMillis] (rather
  /// than the `DateTime` itself) keeps this family provider's cache key a
  /// plain comparable value.
  AnnouncementSeenCountProvider._({
    required AnnouncementSeenCountFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'announcementSeenCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$announcementSeenCountHash();

  @override
  String toString() {
    return r'announcementSeenCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as int;
    return announcementSeenCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AnnouncementSeenCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$announcementSeenCountHash() =>
    r'b581965b37921c4adbeeb6163073b31839f3132b';

/// How many people have seen a given broadcast — anyone who opened the
/// Announcements screen at or after it was sent. [sentAtMillis] (rather
/// than the `DateTime` itself) keeps this family provider's cache key a
/// plain comparable value.

final class AnnouncementSeenCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, int> {
  AnnouncementSeenCountFamily._()
    : super(
        retry: null,
        name: r'announcementSeenCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How many people have seen a given broadcast — anyone who opened the
  /// Announcements screen at or after it was sent. [sentAtMillis] (rather
  /// than the `DateTime` itself) keeps this family provider's cache key a
  /// plain comparable value.

  AnnouncementSeenCountProvider call(int sentAtMillis) =>
      AnnouncementSeenCountProvider._(argument: sentAtMillis, from: this);

  @override
  String toString() => r'announcementSeenCountProvider';
}

/// The uids of everyone who has seen a given broadcast — for the "who has
/// seen this" list, opened on demand from the Broadcast screen.

@ProviderFor(announcementSeenUserIds)
final announcementSeenUserIdsProvider = AnnouncementSeenUserIdsFamily._();

/// The uids of everyone who has seen a given broadcast — for the "who has
/// seen this" list, opened on demand from the Broadcast screen.

final class AnnouncementSeenUserIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// The uids of everyone who has seen a given broadcast — for the "who has
  /// seen this" list, opened on demand from the Broadcast screen.
  AnnouncementSeenUserIdsProvider._({
    required AnnouncementSeenUserIdsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'announcementSeenUserIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$announcementSeenUserIdsHash();

  @override
  String toString() {
    return r'announcementSeenUserIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as int;
    return announcementSeenUserIds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AnnouncementSeenUserIdsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$announcementSeenUserIdsHash() =>
    r'9b0fa3e1e54bf1492b761819492d040a593ed3f0';

/// The uids of everyone who has seen a given broadcast — for the "who has
/// seen this" list, opened on demand from the Broadcast screen.

final class AnnouncementSeenUserIdsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, int> {
  AnnouncementSeenUserIdsFamily._()
    : super(
        retry: null,
        name: r'announcementSeenUserIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The uids of everyone who has seen a given broadcast — for the "who has
  /// seen this" list, opened on demand from the Broadcast screen.

  AnnouncementSeenUserIdsProvider call(int sentAtMillis) =>
      AnnouncementSeenUserIdsProvider._(argument: sentAtMillis, from: this);

  @override
  String toString() => r'announcementSeenUserIdsProvider';
}
