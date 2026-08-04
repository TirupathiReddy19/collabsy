// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_staff_login_event_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminStaffLoginEventRepository)
final adminStaffLoginEventRepositoryProvider =
    AdminStaffLoginEventRepositoryProvider._();

final class AdminStaffLoginEventRepositoryProvider
    extends
        $FunctionalProvider<
          AdminStaffLoginEventRepository,
          AdminStaffLoginEventRepository,
          AdminStaffLoginEventRepository
        >
    with $Provider<AdminStaffLoginEventRepository> {
  AdminStaffLoginEventRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminStaffLoginEventRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminStaffLoginEventRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminStaffLoginEventRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminStaffLoginEventRepository create(Ref ref) {
    return adminStaffLoginEventRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminStaffLoginEventRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminStaffLoginEventRepository>(
        value,
      ),
    );
  }
}

String _$adminStaffLoginEventRepositoryHash() =>
    r'488e5c3cfc84bd30d0aa06563a5111c9235158d9';

/// A single staff account's session history, newest first — sorted
/// client-side (matches `allStaffAccountsProvider`'s own convention) rather
/// than a server-side `.orderBy()`, since that would need a new composite
/// index (`firestore.indexes.json` currently defines none).

@ProviderFor(staffLoginEvents)
final staffLoginEventsProvider = StaffLoginEventsFamily._();

/// A single staff account's session history, newest first — sorted
/// client-side (matches `allStaffAccountsProvider`'s own convention) rather
/// than a server-side `.orderBy()`, since that would need a new composite
/// index (`firestore.indexes.json` currently defines none).

final class StaffLoginEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StaffLoginEvent>>,
          List<StaffLoginEvent>,
          Stream<List<StaffLoginEvent>>
        >
    with
        $FutureModifier<List<StaffLoginEvent>>,
        $StreamProvider<List<StaffLoginEvent>> {
  /// A single staff account's session history, newest first — sorted
  /// client-side (matches `allStaffAccountsProvider`'s own convention) rather
  /// than a server-side `.orderBy()`, since that would need a new composite
  /// index (`firestore.indexes.json` currently defines none).
  StaffLoginEventsProvider._({
    required StaffLoginEventsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'staffLoginEventsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$staffLoginEventsHash();

  @override
  String toString() {
    return r'staffLoginEventsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<StaffLoginEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StaffLoginEvent>> create(Ref ref) {
    final argument = this.argument as String;
    return staffLoginEvents(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StaffLoginEventsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$staffLoginEventsHash() => r'ca2fceb718d9de0a106dff8d17950f236ef6362c';

/// A single staff account's session history, newest first — sorted
/// client-side (matches `allStaffAccountsProvider`'s own convention) rather
/// than a server-side `.orderBy()`, since that would need a new composite
/// index (`firestore.indexes.json` currently defines none).

final class StaffLoginEventsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<StaffLoginEvent>>, String> {
  StaffLoginEventsFamily._()
    : super(
        retry: null,
        name: r'staffLoginEventsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A single staff account's session history, newest first — sorted
  /// client-side (matches `allStaffAccountsProvider`'s own convention) rather
  /// than a server-side `.orderBy()`, since that would need a new composite
  /// index (`firestore.indexes.json` currently defines none).

  StaffLoginEventsProvider call(String uid) =>
      StaffLoginEventsProvider._(argument: uid, from: this);

  @override
  String toString() => r'staffLoginEventsProvider';
}
