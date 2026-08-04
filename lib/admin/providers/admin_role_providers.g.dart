// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_role_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminRoleRepository)
final adminRoleRepositoryProvider = AdminRoleRepositoryProvider._();

final class AdminRoleRepositoryProvider
    extends
        $FunctionalProvider<
          AdminRoleRepository,
          AdminRoleRepository,
          AdminRoleRepository
        >
    with $Provider<AdminRoleRepository> {
  AdminRoleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminRoleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminRoleRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminRoleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminRoleRepository create(Ref ref) {
    return adminRoleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminRoleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminRoleRepository>(value),
    );
  }
}

String _$adminRoleRepositoryHash() =>
    r'6864a5439050e6555c24fb838abc314257edb297';

@ProviderFor(allStaffAccounts)
final allStaffAccountsProvider = AllStaffAccountsProvider._();

final class AllStaffAccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StaffAccount>>,
          List<StaffAccount>,
          Stream<List<StaffAccount>>
        >
    with
        $FutureModifier<List<StaffAccount>>,
        $StreamProvider<List<StaffAccount>> {
  AllStaffAccountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allStaffAccountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allStaffAccountsHash();

  @$internal
  @override
  $StreamProviderElement<List<StaffAccount>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StaffAccount>> create(Ref ref) {
    return allStaffAccounts(ref);
  }
}

String _$allStaffAccountsHash() => r'4570a13f9e8b1c85b8265c5cc9ac3c9f81be31fc';

/// Last-sign-in time per staff uid — re-fetched whenever the staff list
/// changes (e.g. a new account is created).

@ProviderFor(staffLastSignIn)
final staffLastSignInProvider = StaffLastSignInProvider._();

/// Last-sign-in time per staff uid — re-fetched whenever the staff list
/// changes (e.g. a new account is created).

final class StaffLastSignInProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, DateTime?>>,
          Map<String, DateTime?>,
          FutureOr<Map<String, DateTime?>>
        >
    with
        $FutureModifier<Map<String, DateTime?>>,
        $FutureProvider<Map<String, DateTime?>> {
  /// Last-sign-in time per staff uid — re-fetched whenever the staff list
  /// changes (e.g. a new account is created).
  StaffLastSignInProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'staffLastSignInProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$staffLastSignInHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, DateTime?>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, DateTime?>> create(Ref ref) {
    return staffLastSignIn(ref);
  }
}

String _$staffLastSignInHash() => r'a96b8856532fdd0553583c17d6afbb10914660b2';
