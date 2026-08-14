// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_intern_shift_report_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every intern's `internShiftStats` doc for [date] — see
/// `lib/intern/providers/intern_shift_providers.dart` for the write side.

@ProviderFor(allInternShiftStatsForDate)
final allInternShiftStatsForDateProvider = AllInternShiftStatsForDateFamily._();

/// Every intern's `internShiftStats` doc for [date] — see
/// `lib/intern/providers/intern_shift_providers.dart` for the write side.

final class AllInternShiftStatsForDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InternShiftStat>>,
          List<InternShiftStat>,
          Stream<List<InternShiftStat>>
        >
    with
        $FutureModifier<List<InternShiftStat>>,
        $StreamProvider<List<InternShiftStat>> {
  /// Every intern's `internShiftStats` doc for [date] — see
  /// `lib/intern/providers/intern_shift_providers.dart` for the write side.
  AllInternShiftStatsForDateProvider._({
    required AllInternShiftStatsForDateFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'allInternShiftStatsForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$allInternShiftStatsForDateHash();

  @override
  String toString() {
    return r'allInternShiftStatsForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<InternShiftStat>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<InternShiftStat>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return allInternShiftStatsForDate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AllInternShiftStatsForDateProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$allInternShiftStatsForDateHash() =>
    r'9189fe2edae255bc63b5671a4f075c32c0a1e219';

/// Every intern's `internShiftStats` doc for [date] — see
/// `lib/intern/providers/intern_shift_providers.dart` for the write side.

final class AllInternShiftStatsForDateFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<InternShiftStat>>, DateTime> {
  AllInternShiftStatsForDateFamily._()
    : super(
        retry: null,
        name: r'allInternShiftStatsForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every intern's `internShiftStats` doc for [date] — see
  /// `lib/intern/providers/intern_shift_providers.dart` for the write side.

  AllInternShiftStatsForDateProvider call(DateTime date) =>
      AllInternShiftStatsForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'allInternShiftStatsForDateProvider';
}

/// Number of `leads` each intern created on [date], keyed by `internId` —
/// same "messages sent" count the intern tool itself shows, computed here
/// across every intern instead of just the signed-in one. Carries
/// `internEmail` too so an intern who sent messages but has no
/// `internShiftStats` doc yet (e.g. very first tick hasn't landed) still
/// shows up by name in the report.

@ProviderFor(internMessageCountsForDate)
final internMessageCountsForDateProvider = InternMessageCountsForDateFamily._();

/// Number of `leads` each intern created on [date], keyed by `internId` —
/// same "messages sent" count the intern tool itself shows, computed here
/// across every intern instead of just the signed-in one. Carries
/// `internEmail` too so an intern who sent messages but has no
/// `internShiftStats` doc yet (e.g. very first tick hasn't landed) still
/// shows up by name in the report.

final class InternMessageCountsForDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, InternMessageCount>>,
          Map<String, InternMessageCount>,
          Stream<Map<String, InternMessageCount>>
        >
    with
        $FutureModifier<Map<String, InternMessageCount>>,
        $StreamProvider<Map<String, InternMessageCount>> {
  /// Number of `leads` each intern created on [date], keyed by `internId` —
  /// same "messages sent" count the intern tool itself shows, computed here
  /// across every intern instead of just the signed-in one. Carries
  /// `internEmail` too so an intern who sent messages but has no
  /// `internShiftStats` doc yet (e.g. very first tick hasn't landed) still
  /// shows up by name in the report.
  InternMessageCountsForDateProvider._({
    required InternMessageCountsForDateFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'internMessageCountsForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$internMessageCountsForDateHash();

  @override
  String toString() {
    return r'internMessageCountsForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, InternMessageCount>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, InternMessageCount>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return internMessageCountsForDate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InternMessageCountsForDateProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$internMessageCountsForDateHash() =>
    r'3c5db83a293bc42405c86f1d820870d01a444c79';

/// Number of `leads` each intern created on [date], keyed by `internId` —
/// same "messages sent" count the intern tool itself shows, computed here
/// across every intern instead of just the signed-in one. Carries
/// `internEmail` too so an intern who sent messages but has no
/// `internShiftStats` doc yet (e.g. very first tick hasn't landed) still
/// shows up by name in the report.

final class InternMessageCountsForDateFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Map<String, InternMessageCount>>,
          DateTime
        > {
  InternMessageCountsForDateFamily._()
    : super(
        retry: null,
        name: r'internMessageCountsForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Number of `leads` each intern created on [date], keyed by `internId` —
  /// same "messages sent" count the intern tool itself shows, computed here
  /// across every intern instead of just the signed-in one. Carries
  /// `internEmail` too so an intern who sent messages but has no
  /// `internShiftStats` doc yet (e.g. very first tick hasn't landed) still
  /// shows up by name in the report.

  InternMessageCountsForDateProvider call(DateTime date) =>
      InternMessageCountsForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'internMessageCountsForDateProvider';
}
