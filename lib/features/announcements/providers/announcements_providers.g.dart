// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcements_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(announcementsRepository)
final announcementsRepositoryProvider = AnnouncementsRepositoryProvider._();

final class AnnouncementsRepositoryProvider
    extends
        $FunctionalProvider<
          AnnouncementsRepository,
          AnnouncementsRepository,
          AnnouncementsRepository
        >
    with $Provider<AnnouncementsRepository> {
  AnnouncementsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AnnouncementsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnnouncementsRepository create(Ref ref) {
    return announcementsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnnouncementsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnnouncementsRepository>(value),
    );
  }
}

String _$announcementsRepositoryHash() =>
    r'b15eb0bce07f90466d12348eb7273737ed2b0578';

/// Every broadcast aimed at the signed-in user's role — the Messages tab's
/// pinned "Collabsy Team" card and the Announcements screen both watch this.
/// For a Creator, this also narrows down to broadcasts whose audience
/// targeting (category/follower range/specific creator) actually matches
/// them — `watchForRole` only filters by role, so a second, client-side
/// pass is needed for the finer targeting dimensions (same reason Brand
/// Discover's category filter is client-side rather than a Firestore
/// `where`).

@ProviderFor(myAnnouncements)
final myAnnouncementsProvider = MyAnnouncementsProvider._();

/// Every broadcast aimed at the signed-in user's role — the Messages tab's
/// pinned "Collabsy Team" card and the Announcements screen both watch this.
/// For a Creator, this also narrows down to broadcasts whose audience
/// targeting (category/follower range/specific creator) actually matches
/// them — `watchForRole` only filters by role, so a second, client-side
/// pass is needed for the finer targeting dimensions (same reason Brand
/// Discover's category filter is client-side rather than a Firestore
/// `where`).

final class MyAnnouncementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Announcement>>,
          List<Announcement>,
          Stream<List<Announcement>>
        >
    with
        $FutureModifier<List<Announcement>>,
        $StreamProvider<List<Announcement>> {
  /// Every broadcast aimed at the signed-in user's role — the Messages tab's
  /// pinned "Collabsy Team" card and the Announcements screen both watch this.
  /// For a Creator, this also narrows down to broadcasts whose audience
  /// targeting (category/follower range/specific creator) actually matches
  /// them — `watchForRole` only filters by role, so a second, client-side
  /// pass is needed for the finer targeting dimensions (same reason Brand
  /// Discover's category filter is client-side rather than a Firestore
  /// `where`).
  MyAnnouncementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myAnnouncementsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myAnnouncementsHash();

  @$internal
  @override
  $StreamProviderElement<List<Announcement>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Announcement>> create(Ref ref) {
    return myAnnouncements(ref);
  }
}

String _$myAnnouncementsHash() => r'a5294bb31c99e3e621a3643ebfba7b9f0cf3f8bc';

@ProviderFor(myAnnouncementsLastRead)
final myAnnouncementsLastReadProvider = MyAnnouncementsLastReadProvider._();

final class MyAnnouncementsLastReadProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime?>, DateTime?, Stream<DateTime?>>
    with $FutureModifier<DateTime?>, $StreamProvider<DateTime?> {
  MyAnnouncementsLastReadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myAnnouncementsLastReadProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myAnnouncementsLastReadHash();

  @$internal
  @override
  $StreamProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime?> create(Ref ref) {
    return myAnnouncementsLastRead(ref);
  }
}

String _$myAnnouncementsLastReadHash() =>
    r'83d706d1b0450a7dd73c12087e695faeed405cad';

/// True when the newest broadcast is newer than the last time this user
/// opened the Announcements screen (or they've never opened it at all).

@ProviderFor(hasUnreadAnnouncements)
final hasUnreadAnnouncementsProvider = HasUnreadAnnouncementsProvider._();

/// True when the newest broadcast is newer than the last time this user
/// opened the Announcements screen (or they've never opened it at all).

final class HasUnreadAnnouncementsProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// True when the newest broadcast is newer than the last time this user
  /// opened the Announcements screen (or they've never opened it at all).
  HasUnreadAnnouncementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasUnreadAnnouncementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasUnreadAnnouncementsHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasUnreadAnnouncements(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasUnreadAnnouncementsHash() =>
    r'6624e63f5b1ee6c8773ce052b0c47a0d765688fb';

/// Marks all broadcasts as read — called once the Announcements screen
/// opens.

@ProviderFor(AnnouncementsController)
final announcementsControllerProvider = AnnouncementsControllerProvider._();

/// Marks all broadcasts as read — called once the Announcements screen
/// opens.
final class AnnouncementsControllerProvider
    extends $AsyncNotifierProvider<AnnouncementsController, void> {
  /// Marks all broadcasts as read — called once the Announcements screen
  /// opens.
  AnnouncementsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementsControllerHash();

  @$internal
  @override
  AnnouncementsController create() => AnnouncementsController();
}

String _$announcementsControllerHash() =>
    r'98532c3663d4805e4df4dc3a5999bbdfe4229ded';

/// Marks all broadcasts as read — called once the Announcements screen
/// opens.

abstract class _$AnnouncementsController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
