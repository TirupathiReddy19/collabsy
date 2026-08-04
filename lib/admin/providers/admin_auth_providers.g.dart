// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the currently signed-in Firebase user (if any) is the admin
/// account. Client-side only, for instant UI/redirect purposes — the real
/// enforcement is server-side, in Firestore security rules, which check
/// this same email on every request regardless of what the client claims.

@ProviderFor(isAdmin)
final isAdminProvider = IsAdminProvider._();

/// Whether the currently signed-in Firebase user (if any) is the admin
/// account. Client-side only, for instant UI/redirect purposes — the real
/// enforcement is server-side, in Firestore security rules, which check
/// this same email on every request regardless of what the client claims.

final class IsAdminProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the currently signed-in Firebase user (if any) is the admin
  /// account. Client-side only, for instant UI/redirect purposes — the real
  /// enforcement is server-side, in Firestore security rules, which check
  /// this same email on every request regardless of what the client claims.
  IsAdminProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAdminProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAdminHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAdmin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAdminHash() => r'e406863d1aaed7eb197701b33e89127d4ea67c94';

/// The real signed-in email for whoever is currently using the admin
/// portal — super admin or staff — so audit-log entries attribute to the
/// actual account instead of always saying `adminEmail`.

@ProviderFor(currentAdminEmail)
final currentAdminEmailProvider = CurrentAdminEmailProvider._();

/// The real signed-in email for whoever is currently using the admin
/// portal — super admin or staff — so audit-log entries attribute to the
/// actual account instead of always saying `adminEmail`.

final class CurrentAdminEmailProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The real signed-in email for whoever is currently using the admin
  /// portal — super admin or staff — so audit-log entries attribute to the
  /// actual account instead of always saying `adminEmail`.
  CurrentAdminEmailProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAdminEmailProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAdminEmailHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentAdminEmail(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentAdminEmailHash() => r'ea38922ee540552cd8626f0e6ea0afb2771e1d85';

/// The signed-in staff account's own `staffAccounts` doc, live — `null` for
/// the super admin (unrestricted, no doc exists for them) or when signed
/// out. Used by the sidebar to filter nav items and show the real
/// role/email; NOT used for the router's redirect guard, which needs a
/// one-shot, cached-per-session read instead of a live stream (see
/// admin_router.dart for why).

@ProviderFor(currentStaffAccount)
final currentStaffAccountProvider = CurrentStaffAccountProvider._();

/// The signed-in staff account's own `staffAccounts` doc, live — `null` for
/// the super admin (unrestricted, no doc exists for them) or when signed
/// out. Used by the sidebar to filter nav items and show the real
/// role/email; NOT used for the router's redirect guard, which needs a
/// one-shot, cached-per-session read instead of a live stream (see
/// admin_router.dart for why).

final class CurrentStaffAccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<StaffAccount?>,
          StaffAccount?,
          Stream<StaffAccount?>
        >
    with $FutureModifier<StaffAccount?>, $StreamProvider<StaffAccount?> {
  /// The signed-in staff account's own `staffAccounts` doc, live — `null` for
  /// the super admin (unrestricted, no doc exists for them) or when signed
  /// out. Used by the sidebar to filter nav items and show the real
  /// role/email; NOT used for the router's redirect guard, which needs a
  /// one-shot, cached-per-session read instead of a live stream (see
  /// admin_router.dart for why).
  CurrentStaffAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentStaffAccountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentStaffAccountHash();

  @$internal
  @override
  $StreamProviderElement<StaffAccount?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StaffAccount?> create(Ref ref) {
    return currentStaffAccount(ref);
  }
}

String _$currentStaffAccountHash() =>
    r'100ead0a74e3923a82b4bff57d810c834543db00';
