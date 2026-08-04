// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_audit_log_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminAuditLogRepository)
final adminAuditLogRepositoryProvider = AdminAuditLogRepositoryProvider._();

final class AdminAuditLogRepositoryProvider
    extends
        $FunctionalProvider<
          AdminAuditLogRepository,
          AdminAuditLogRepository,
          AdminAuditLogRepository
        >
    with $Provider<AdminAuditLogRepository> {
  AdminAuditLogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminAuditLogRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminAuditLogRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminAuditLogRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminAuditLogRepository create(Ref ref) {
    return adminAuditLogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminAuditLogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminAuditLogRepository>(value),
    );
  }
}

String _$adminAuditLogRepositoryHash() =>
    r'0c9c33416209b36e75239a45ed789f5e7ea9cc85';

@ProviderFor(allAuditLogs)
final allAuditLogsProvider = AllAuditLogsProvider._();

final class AllAuditLogsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AuditLogEntry>>,
          List<AuditLogEntry>,
          Stream<List<AuditLogEntry>>
        >
    with
        $FutureModifier<List<AuditLogEntry>>,
        $StreamProvider<List<AuditLogEntry>> {
  AllAuditLogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allAuditLogsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allAuditLogsHash();

  @$internal
  @override
  $StreamProviderElement<List<AuditLogEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AuditLogEntry>> create(Ref ref) {
    return allAuditLogs(ref);
  }
}

String _$allAuditLogsHash() => r'aa2b6226d4f8aa25fe1d0f7c600cd27460532661';
