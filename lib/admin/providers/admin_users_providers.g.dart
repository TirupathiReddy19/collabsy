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
