// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'fe938e610a206ac71348516f849c39f438ca0cd9';

@ProviderFor(authStateChanges)
final authStateChangesProvider = AuthStateChangesProvider._();

final class AuthStateChangesProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  AuthStateChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateChangesHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authStateChanges(ref);
  }
}

String _$authStateChangesHash() => r'6ba32c3e1d6153681f96e544b51a9e393ed4edef';

/// The signed-in user's `users` Firestore document (including chosen
/// [UserRole]), or null when there's no session. Refetches whenever auth
/// state changes.

@ProviderFor(CurrentProfile)
final currentProfileProvider = CurrentProfileProvider._();

/// The signed-in user's `users` Firestore document (including chosen
/// [UserRole]), or null when there's no session. Refetches whenever auth
/// state changes.
final class CurrentProfileProvider
    extends $AsyncNotifierProvider<CurrentProfile, AppUserProfile?> {
  /// The signed-in user's `users` Firestore document (including chosen
  /// [UserRole]), or null when there's no session. Refetches whenever auth
  /// state changes.
  CurrentProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentProfileHash();

  @$internal
  @override
  CurrentProfile create() => CurrentProfile();
}

String _$currentProfileHash() => r'ed13953d5884d3b12cb7be329ab69b75b36251ef';

/// The signed-in user's `users` Firestore document (including chosen
/// [UserRole]), or null when there's no session. Refetches whenever auth
/// state changes.

abstract class _$CurrentProfile extends $AsyncNotifier<AppUserProfile?> {
  FutureOr<AppUserProfile?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppUserProfile?>, AppUserProfile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppUserProfile?>, AppUserProfile?>,
              AsyncValue<AppUserProfile?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// A genuine live listener on the signed-in user's own profile doc (unlike
/// [currentProfileProvider], which is a one-shot fetch re-run only on auth
/// changes or an explicit invalidate) — this is what lets the router notice
/// an admin suspending the account within moments, mid-session, instead of
/// only on the next relaunch. See the router's `redirect` +
/// `refreshListenable`.

@ProviderFor(currentProfileWatch)
final currentProfileWatchProvider = CurrentProfileWatchProvider._();

/// A genuine live listener on the signed-in user's own profile doc (unlike
/// [currentProfileProvider], which is a one-shot fetch re-run only on auth
/// changes or an explicit invalidate) — this is what lets the router notice
/// an admin suspending the account within moments, mid-session, instead of
/// only on the next relaunch. See the router's `redirect` +
/// `refreshListenable`.

final class CurrentProfileWatchProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppUserProfile?>,
          AppUserProfile?,
          Stream<AppUserProfile?>
        >
    with $FutureModifier<AppUserProfile?>, $StreamProvider<AppUserProfile?> {
  /// A genuine live listener on the signed-in user's own profile doc (unlike
  /// [currentProfileProvider], which is a one-shot fetch re-run only on auth
  /// changes or an explicit invalidate) — this is what lets the router notice
  /// an admin suspending the account within moments, mid-session, instead of
  /// only on the next relaunch. See the router's `redirect` +
  /// `refreshListenable`.
  CurrentProfileWatchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentProfileWatchProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentProfileWatchHash();

  @$internal
  @override
  $StreamProviderElement<AppUserProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppUserProfile?> create(Ref ref) {
    return currentProfileWatch(ref);
  }
}

String _$currentProfileWatchHash() =>
    r'bed978b2617e4e5f9dc24362629183cf5fc3edf0';

/// A specific user's `users` document by ID — for showing another user's
/// avatar/display name (e.g. a Creator's manually-uploaded photo on the
/// Brand-facing public profile), as opposed to [currentProfileProvider]
/// which is always the signed-in user's own.

@ProviderFor(appUserProfileById)
final appUserProfileByIdProvider = AppUserProfileByIdFamily._();

/// A specific user's `users` document by ID — for showing another user's
/// avatar/display name (e.g. a Creator's manually-uploaded photo on the
/// Brand-facing public profile), as opposed to [currentProfileProvider]
/// which is always the signed-in user's own.

final class AppUserProfileByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppUserProfile?>,
          AppUserProfile?,
          FutureOr<AppUserProfile?>
        >
    with $FutureModifier<AppUserProfile?>, $FutureProvider<AppUserProfile?> {
  /// A specific user's `users` document by ID — for showing another user's
  /// avatar/display name (e.g. a Creator's manually-uploaded photo on the
  /// Brand-facing public profile), as opposed to [currentProfileProvider]
  /// which is always the signed-in user's own.
  AppUserProfileByIdProvider._({
    required AppUserProfileByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'appUserProfileByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$appUserProfileByIdHash();

  @override
  String toString() {
    return r'appUserProfileByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AppUserProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AppUserProfile?> create(Ref ref) {
    final argument = this.argument as String;
    return appUserProfileById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AppUserProfileByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$appUserProfileByIdHash() =>
    r'b56b7b5dfb6ab8c6c9edb2b3b75e0f2eebf3fe9c';

/// A specific user's `users` document by ID — for showing another user's
/// avatar/display name (e.g. a Creator's manually-uploaded photo on the
/// Brand-facing public profile), as opposed to [currentProfileProvider]
/// which is always the signed-in user's own.

final class AppUserProfileByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AppUserProfile?>, String> {
  AppUserProfileByIdFamily._()
    : super(
        retry: null,
        name: r'appUserProfileByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A specific user's `users` document by ID — for showing another user's
  /// avatar/display name (e.g. a Creator's manually-uploaded photo on the
  /// Brand-facing public profile), as opposed to [currentProfileProvider]
  /// which is always the signed-in user's own.

  AppUserProfileByIdProvider call(String userId) =>
      AppUserProfileByIdProvider._(argument: userId, from: this);

  @override
  String toString() => r'appUserProfileByIdProvider';
}

/// Holds the data the OTP screen needs, set by whichever screen navigates
/// to it. Deliberately not passed via GoRouter's route `extra` — that gets
/// dropped when the router re-evaluates its redirect guard mid-flow (e.g.
/// the moment phone verification itself changes the signed-in auth state),
/// which crashed the OTP screen's route builder. Provider state survives
/// that; `extra` doesn't.

@ProviderFor(PendingOtp)
final pendingOtpProvider = PendingOtpProvider._();

/// Holds the data the OTP screen needs, set by whichever screen navigates
/// to it. Deliberately not passed via GoRouter's route `extra` — that gets
/// dropped when the router re-evaluates its redirect guard mid-flow (e.g.
/// the moment phone verification itself changes the signed-in auth state),
/// which crashed the OTP screen's route builder. Provider state survives
/// that; `extra` doesn't.
final class PendingOtpProvider
    extends $NotifierProvider<PendingOtp, OtpVerificationArgs?> {
  /// Holds the data the OTP screen needs, set by whichever screen navigates
  /// to it. Deliberately not passed via GoRouter's route `extra` — that gets
  /// dropped when the router re-evaluates its redirect guard mid-flow (e.g.
  /// the moment phone verification itself changes the signed-in auth state),
  /// which crashed the OTP screen's route builder. Provider state survives
  /// that; `extra` doesn't.
  PendingOtpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingOtpProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingOtpHash();

  @$internal
  @override
  PendingOtp create() => PendingOtp();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OtpVerificationArgs? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OtpVerificationArgs?>(value),
    );
  }
}

String _$pendingOtpHash() => r'ebf7afe5acc5079efafb529f949eebbe75cca09a';

/// Holds the data the OTP screen needs, set by whichever screen navigates
/// to it. Deliberately not passed via GoRouter's route `extra` — that gets
/// dropped when the router re-evaluates its redirect guard mid-flow (e.g.
/// the moment phone verification itself changes the signed-in auth state),
/// which crashed the OTP screen's route builder. Provider state survives
/// that; `extra` doesn't.

abstract class _$PendingOtp extends $Notifier<OtpVerificationArgs?> {
  OtpVerificationArgs? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OtpVerificationArgs?, OtpVerificationArgs?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OtpVerificationArgs?, OtpVerificationArgs?>,
              OtpVerificationArgs?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Holds the in-progress sign-in [MultiFactorResolver] once
/// [AuthController.signInWithPassword] hits a [FirebaseAuthMultiFactorException]
/// — same "provider state survives router redirects, route `extra` doesn't"
/// reasoning as [PendingOtp].

@ProviderFor(PendingMfaResolver)
final pendingMfaResolverProvider = PendingMfaResolverProvider._();

/// Holds the in-progress sign-in [MultiFactorResolver] once
/// [AuthController.signInWithPassword] hits a [FirebaseAuthMultiFactorException]
/// — same "provider state survives router redirects, route `extra` doesn't"
/// reasoning as [PendingOtp].
final class PendingMfaResolverProvider
    extends $NotifierProvider<PendingMfaResolver, MultiFactorResolver?> {
  /// Holds the in-progress sign-in [MultiFactorResolver] once
  /// [AuthController.signInWithPassword] hits a [FirebaseAuthMultiFactorException]
  /// — same "provider state survives router redirects, route `extra` doesn't"
  /// reasoning as [PendingOtp].
  PendingMfaResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingMfaResolverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingMfaResolverHash();

  @$internal
  @override
  PendingMfaResolver create() => PendingMfaResolver();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MultiFactorResolver? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MultiFactorResolver?>(value),
    );
  }
}

String _$pendingMfaResolverHash() =>
    r'285feec9ca85088c4a3274a77d63fd156324039b';

/// Holds the in-progress sign-in [MultiFactorResolver] once
/// [AuthController.signInWithPassword] hits a [FirebaseAuthMultiFactorException]
/// — same "provider state survives router redirects, route `extra` doesn't"
/// reasoning as [PendingOtp].

abstract class _$PendingMfaResolver extends $Notifier<MultiFactorResolver?> {
  MultiFactorResolver? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MultiFactorResolver?, MultiFactorResolver?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MultiFactorResolver?, MultiFactorResolver?>,
              MultiFactorResolver?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Drives the auth screens' sign-up/sign-in/verify/Google/sign-out actions
/// and exposes their loading/error state.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Drives the auth screens' sign-up/sign-in/verify/Google/sign-out actions
/// and exposes their loading/error state.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, void> {
  /// Drives the auth screens' sign-up/sign-in/verify/Google/sign-out actions
  /// and exposes their loading/error state.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'e82dee857ef01ad9de9421c0b8470ed5f2485698';

/// Drives the auth screens' sign-up/sign-in/verify/Google/sign-out actions
/// and exposes their loading/error state.

abstract class _$AuthController extends $AsyncNotifier<void> {
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
