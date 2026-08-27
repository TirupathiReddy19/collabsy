// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_crash_analytics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Calls the `getCrashAnalytics` Cloud Function, which queries Crashlytics'
/// BigQuery export directly — there's no Firestore copy of this data, so
/// unlike every other admin analytics provider this is a one-shot Future,
/// not a live stream. Requires the Crashlytics -> BigQuery link to be
/// turned on in Firebase Console; until then (or until the first export
/// has actually run) this returns empty trend/topIssues rather than an
/// error, since a missing BigQuery table is expected, not exceptional.

@ProviderFor(crashAnalytics)
final crashAnalyticsProvider = CrashAnalyticsFamily._();

/// Calls the `getCrashAnalytics` Cloud Function, which queries Crashlytics'
/// BigQuery export directly — there's no Firestore copy of this data, so
/// unlike every other admin analytics provider this is a one-shot Future,
/// not a live stream. Requires the Crashlytics -> BigQuery link to be
/// turned on in Firebase Console; until then (or until the first export
/// has actually run) this returns empty trend/topIssues rather than an
/// error, since a missing BigQuery table is expected, not exceptional.

final class CrashAnalyticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<CrashAnalytics>,
          CrashAnalytics,
          FutureOr<CrashAnalytics>
        >
    with $FutureModifier<CrashAnalytics>, $FutureProvider<CrashAnalytics> {
  /// Calls the `getCrashAnalytics` Cloud Function, which queries Crashlytics'
  /// BigQuery export directly — there's no Firestore copy of this data, so
  /// unlike every other admin analytics provider this is a one-shot Future,
  /// not a live stream. Requires the Crashlytics -> BigQuery link to be
  /// turned on in Firebase Console; until then (or until the first export
  /// has actually run) this returns empty trend/topIssues rather than an
  /// error, since a missing BigQuery table is expected, not exceptional.
  CrashAnalyticsProvider._({
    required CrashAnalyticsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'crashAnalyticsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$crashAnalyticsHash();

  @override
  String toString() {
    return r'crashAnalyticsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CrashAnalytics> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CrashAnalytics> create(Ref ref) {
    final argument = this.argument as int;
    return crashAnalytics(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CrashAnalyticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crashAnalyticsHash() => r'52bb8c8e7428487fd46a790c34bdc379ea584148';

/// Calls the `getCrashAnalytics` Cloud Function, which queries Crashlytics'
/// BigQuery export directly — there's no Firestore copy of this data, so
/// unlike every other admin analytics provider this is a one-shot Future,
/// not a live stream. Requires the Crashlytics -> BigQuery link to be
/// turned on in Firebase Console; until then (or until the first export
/// has actually run) this returns empty trend/topIssues rather than an
/// error, since a missing BigQuery table is expected, not exceptional.

final class CrashAnalyticsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CrashAnalytics>, int> {
  CrashAnalyticsFamily._()
    : super(
        retry: null,
        name: r'crashAnalyticsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Calls the `getCrashAnalytics` Cloud Function, which queries Crashlytics'
  /// BigQuery export directly — there's no Firestore copy of this data, so
  /// unlike every other admin analytics provider this is a one-shot Future,
  /// not a live stream. Requires the Crashlytics -> BigQuery link to be
  /// turned on in Firebase Console; until then (or until the first export
  /// has actually run) this returns empty trend/topIssues rather than an
  /// error, since a missing BigQuery table is expected, not exceptional.

  CrashAnalyticsProvider call(int days) =>
      CrashAnalyticsProvider._(argument: days, from: this);

  @override
  String toString() => r'crashAnalyticsProvider';
}
