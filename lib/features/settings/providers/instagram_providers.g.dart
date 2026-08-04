// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instagram_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(instagramRepository)
final instagramRepositoryProvider = InstagramRepositoryProvider._();

final class InstagramRepositoryProvider
    extends
        $FunctionalProvider<
          InstagramRepository,
          InstagramRepository,
          InstagramRepository
        >
    with $Provider<InstagramRepository> {
  InstagramRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'instagramRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$instagramRepositoryHash();

  @$internal
  @override
  $ProviderElement<InstagramRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InstagramRepository create(Ref ref) {
    return instagramRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InstagramRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InstagramRepository>(value),
    );
  }
}

String _$instagramRepositoryHash() =>
    r'655990d1f601438044c87b1c5fff546a4352e6ec';

@ProviderFor(instagramAuthService)
final instagramAuthServiceProvider = InstagramAuthServiceProvider._();

final class InstagramAuthServiceProvider
    extends
        $FunctionalProvider<
          InstagramAuthService,
          InstagramAuthService,
          InstagramAuthService
        >
    with $Provider<InstagramAuthService> {
  InstagramAuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'instagramAuthServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$instagramAuthServiceHash();

  @$internal
  @override
  $ProviderElement<InstagramAuthService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InstagramAuthService create(Ref ref) {
    return instagramAuthService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InstagramAuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InstagramAuthService>(value),
    );
  }
}

String _$instagramAuthServiceHash() =>
    r'0a43bd17a5180a2973e5eb41f4a31a18eeebc476';

@ProviderFor(ownInstagramAccount)
final ownInstagramAccountProvider = OwnInstagramAccountProvider._();

final class OwnInstagramAccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<InstagramAccount?>,
          InstagramAccount?,
          Stream<InstagramAccount?>
        >
    with
        $FutureModifier<InstagramAccount?>,
        $StreamProvider<InstagramAccount?> {
  OwnInstagramAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ownInstagramAccountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ownInstagramAccountHash();

  @$internal
  @override
  $StreamProviderElement<InstagramAccount?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<InstagramAccount?> create(Ref ref) {
    return ownInstagramAccount(ref);
  }
}

String _$ownInstagramAccountHash() =>
    r'169780f848ac75f19858c71ec57afffdef65e12c';

@ProviderFor(ownInstagramMedia)
final ownInstagramMediaProvider = OwnInstagramMediaProvider._();

final class OwnInstagramMediaProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InstagramMediaItem>>,
          List<InstagramMediaItem>,
          Stream<List<InstagramMediaItem>>
        >
    with
        $FutureModifier<List<InstagramMediaItem>>,
        $StreamProvider<List<InstagramMediaItem>> {
  OwnInstagramMediaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ownInstagramMediaProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ownInstagramMediaHash();

  @$internal
  @override
  $StreamProviderElement<List<InstagramMediaItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<InstagramMediaItem>> create(Ref ref) {
    return ownInstagramMedia(ref);
  }
}

String _$ownInstagramMediaHash() => r'08575fd07b38feed292b3edc01e003e82a69d03d';

/// A specific creator's connected Instagram account, for the Brand-facing
/// public profile view — same data as [ownInstagramAccountProvider], just
/// parameterized by whichever creator is being viewed rather than always
/// the signed-in user.

@ProviderFor(instagramAccountForUser)
final instagramAccountForUserProvider = InstagramAccountForUserFamily._();

/// A specific creator's connected Instagram account, for the Brand-facing
/// public profile view — same data as [ownInstagramAccountProvider], just
/// parameterized by whichever creator is being viewed rather than always
/// the signed-in user.

final class InstagramAccountForUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<InstagramAccount?>,
          InstagramAccount?,
          Stream<InstagramAccount?>
        >
    with
        $FutureModifier<InstagramAccount?>,
        $StreamProvider<InstagramAccount?> {
  /// A specific creator's connected Instagram account, for the Brand-facing
  /// public profile view — same data as [ownInstagramAccountProvider], just
  /// parameterized by whichever creator is being viewed rather than always
  /// the signed-in user.
  InstagramAccountForUserProvider._({
    required InstagramAccountForUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'instagramAccountForUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$instagramAccountForUserHash();

  @override
  String toString() {
    return r'instagramAccountForUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<InstagramAccount?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<InstagramAccount?> create(Ref ref) {
    final argument = this.argument as String;
    return instagramAccountForUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InstagramAccountForUserProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$instagramAccountForUserHash() =>
    r'37df9d319303b2cfc72d58ba67aac4794084478a';

/// A specific creator's connected Instagram account, for the Brand-facing
/// public profile view — same data as [ownInstagramAccountProvider], just
/// parameterized by whichever creator is being viewed rather than always
/// the signed-in user.

final class InstagramAccountForUserFamily extends $Family
    with $FunctionalFamilyOverride<Stream<InstagramAccount?>, String> {
  InstagramAccountForUserFamily._()
    : super(
        retry: null,
        name: r'instagramAccountForUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A specific creator's connected Instagram account, for the Brand-facing
  /// public profile view — same data as [ownInstagramAccountProvider], just
  /// parameterized by whichever creator is being viewed rather than always
  /// the signed-in user.

  InstagramAccountForUserProvider call(String userId) =>
      InstagramAccountForUserProvider._(argument: userId, from: this);

  @override
  String toString() => r'instagramAccountForUserProvider';
}

/// Every connected Instagram account — for the Admin Creators list.

@ProviderFor(allInstagramAccounts)
final allInstagramAccountsProvider = AllInstagramAccountsProvider._();

/// Every connected Instagram account — for the Admin Creators list.

final class AllInstagramAccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InstagramAccount>>,
          List<InstagramAccount>,
          Stream<List<InstagramAccount>>
        >
    with
        $FutureModifier<List<InstagramAccount>>,
        $StreamProvider<List<InstagramAccount>> {
  /// Every connected Instagram account — for the Admin Creators list.
  AllInstagramAccountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allInstagramAccountsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allInstagramAccountsHash();

  @$internal
  @override
  $StreamProviderElement<List<InstagramAccount>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<InstagramAccount>> create(Ref ref) {
    return allInstagramAccounts(ref);
  }
}

String _$allInstagramAccountsHash() =>
    r'be72f81feb2bd6079ca95a5d4e14b41e7bfef367';

/// Drives the Connected Accounts screen's connect/disconnect/refresh
/// actions and their loading/error state.

@ProviderFor(InstagramController)
final instagramControllerProvider = InstagramControllerProvider._();

/// Drives the Connected Accounts screen's connect/disconnect/refresh
/// actions and their loading/error state.
final class InstagramControllerProvider
    extends $AsyncNotifierProvider<InstagramController, void> {
  /// Drives the Connected Accounts screen's connect/disconnect/refresh
  /// actions and their loading/error state.
  InstagramControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'instagramControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$instagramControllerHash();

  @$internal
  @override
  InstagramController create() => InstagramController();
}

String _$instagramControllerHash() =>
    r'8c8dc749d667689ca63ed996ec2181ae7f892db5';

/// Drives the Connected Accounts screen's connect/disconnect/refresh
/// actions and their loading/error state.

abstract class _$InstagramController extends $AsyncNotifier<void> {
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
