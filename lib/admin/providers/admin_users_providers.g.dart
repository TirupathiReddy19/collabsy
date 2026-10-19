// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_users_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every `users` document with the given [role] — the admin-only
/// equivalent of fetching a single profile, but for listing rather than a
/// one-off lookup.

@ProviderFor(usersByRole)
final usersByRoleProvider = UsersByRoleFamily._();

/// Every `users` document with the given [role] — the admin-only
/// equivalent of fetching a single profile, but for listing rather than a
/// one-off lookup.

final class UsersByRoleProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppUserProfile>>,
          List<AppUserProfile>,
          Stream<List<AppUserProfile>>
        >
    with
        $FutureModifier<List<AppUserProfile>>,
        $StreamProvider<List<AppUserProfile>> {
  /// Every `users` document with the given [role] — the admin-only
  /// equivalent of fetching a single profile, but for listing rather than a
  /// one-off lookup.
  UsersByRoleProvider._({
    required UsersByRoleFamily super.from,
    required UserRole super.argument,
  }) : super(
         retry: null,
         name: r'usersByRoleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$usersByRoleHash();

  @override
  String toString() {
    return r'usersByRoleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppUserProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppUserProfile>> create(Ref ref) {
    final argument = this.argument as UserRole;
    return usersByRole(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UsersByRoleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$usersByRoleHash() => r'31b22d7a55304ad36d7a0964539382f08ef77dc7';

/// Every `users` document with the given [role] — the admin-only
/// equivalent of fetching a single profile, but for listing rather than a
/// one-off lookup.

final class UsersByRoleFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AppUserProfile>>, UserRole> {
  UsersByRoleFamily._()
    : super(
        retry: null,
        name: r'usersByRoleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every `users` document with the given [role] — the admin-only
  /// equivalent of fetching a single profile, but for listing rather than a
  /// one-off lookup.

  UsersByRoleProvider call(UserRole role) =>
      UsersByRoleProvider._(argument: role, from: this);

  @override
  String toString() => r'usersByRoleProvider';
}

/// Every [role]'s email/phone in one go, keyed by uid — backs the admin
/// Creators/Brands screens' search and CSV export now that U1 phase B
/// removed the public `email`/`phone` fields those used to read directly.
/// Keyed by [UserRole] rather than the actual id list (a fresh `List`
/// built on every build() is never `==` to the last one, so a family
/// keyed by it would never hit cache) — refetches whenever the underlying
/// user list changes.

@ProviderFor(privateContactsByRole)
final privateContactsByRoleProvider = PrivateContactsByRoleFamily._();

/// Every [role]'s email/phone in one go, keyed by uid — backs the admin
/// Creators/Brands screens' search and CSV export now that U1 phase B
/// removed the public `email`/`phone` fields those used to read directly.
/// Keyed by [UserRole] rather than the actual id list (a fresh `List`
/// built on every build() is never `==` to the last one, so a family
/// keyed by it would never hit cache) — refetches whenever the underlying
/// user list changes.

final class PrivateContactsByRoleProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, Map<String, dynamic>>>,
          Map<String, Map<String, dynamic>>,
          FutureOr<Map<String, Map<String, dynamic>>>
        >
    with
        $FutureModifier<Map<String, Map<String, dynamic>>>,
        $FutureProvider<Map<String, Map<String, dynamic>>> {
  /// Every [role]'s email/phone in one go, keyed by uid — backs the admin
  /// Creators/Brands screens' search and CSV export now that U1 phase B
  /// removed the public `email`/`phone` fields those used to read directly.
  /// Keyed by [UserRole] rather than the actual id list (a fresh `List`
  /// built on every build() is never `==` to the last one, so a family
  /// keyed by it would never hit cache) — refetches whenever the underlying
  /// user list changes.
  PrivateContactsByRoleProvider._({
    required PrivateContactsByRoleFamily super.from,
    required UserRole super.argument,
  }) : super(
         retry: null,
         name: r'privateContactsByRoleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$privateContactsByRoleHash();

  @override
  String toString() {
    return r'privateContactsByRoleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as UserRole;
    return privateContactsByRole(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PrivateContactsByRoleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$privateContactsByRoleHash() =>
    r'6c3eca0417b7af892abc6adb61750e72fc83ae5c';

/// Every [role]'s email/phone in one go, keyed by uid — backs the admin
/// Creators/Brands screens' search and CSV export now that U1 phase B
/// removed the public `email`/`phone` fields those used to read directly.
/// Keyed by [UserRole] rather than the actual id list (a fresh `List`
/// built on every build() is never `==` to the last one, so a family
/// keyed by it would never hit cache) — refetches whenever the underlying
/// user list changes.

final class PrivateContactsByRoleFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, Map<String, dynamic>>>,
          UserRole
        > {
  PrivateContactsByRoleFamily._()
    : super(
        retry: null,
        name: r'privateContactsByRoleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every [role]'s email/phone in one go, keyed by uid — backs the admin
  /// Creators/Brands screens' search and CSV export now that U1 phase B
  /// removed the public `email`/`phone` fields those used to read directly.
  /// Keyed by [UserRole] rather than the actual id list (a fresh `List`
  /// built on every build() is never `==` to the last one, so a family
  /// keyed by it would never hit cache) — refetches whenever the underlying
  /// user list changes.

  PrivateContactsByRoleProvider call(UserRole role) =>
      PrivateContactsByRoleProvider._(argument: role, from: this);

  @override
  String toString() => r'privateContactsByRoleProvider';
}
