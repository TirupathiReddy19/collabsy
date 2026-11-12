// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_brand_outreach_reports_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One row per active brand-outreach intern — their personally-generated
/// `BrandLead` funnel (link sent -> clicked -> signed up -> onboarded)
/// alongside their admin-pushed `BrandProspect` pool (assigned -> contacted
/// -> ever included in a bulk send), the only place both funnels are shown
/// together across every intern. `brandProspects` is scoped per intern
/// (`where assignedTo == uid`) rather than reading the whole collection —
/// same reasoning as `AdminBrandProspectsRepository`'s own comment: it can
/// hold 30k+ docs, not something to pull in full for a report. `brandLeads`
/// is read in full since it's one-by-one manually-found links, a much
/// smaller volume.

@ProviderFor(brandOutreachInternSummaries)
final brandOutreachInternSummariesProvider =
    BrandOutreachInternSummariesProvider._();

/// One row per active brand-outreach intern — their personally-generated
/// `BrandLead` funnel (link sent -> clicked -> signed up -> onboarded)
/// alongside their admin-pushed `BrandProspect` pool (assigned -> contacted
/// -> ever included in a bulk send), the only place both funnels are shown
/// together across every intern. `brandProspects` is scoped per intern
/// (`where assignedTo == uid`) rather than reading the whole collection —
/// same reasoning as `AdminBrandProspectsRepository`'s own comment: it can
/// hold 30k+ docs, not something to pull in full for a report. `brandLeads`
/// is read in full since it's one-by-one manually-found links, a much
/// smaller volume.

final class BrandOutreachInternSummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BrandOutreachInternSummary>>,
          List<BrandOutreachInternSummary>,
          FutureOr<List<BrandOutreachInternSummary>>
        >
    with
        $FutureModifier<List<BrandOutreachInternSummary>>,
        $FutureProvider<List<BrandOutreachInternSummary>> {
  /// One row per active brand-outreach intern — their personally-generated
  /// `BrandLead` funnel (link sent -> clicked -> signed up -> onboarded)
  /// alongside their admin-pushed `BrandProspect` pool (assigned -> contacted
  /// -> ever included in a bulk send), the only place both funnels are shown
  /// together across every intern. `brandProspects` is scoped per intern
  /// (`where assignedTo == uid`) rather than reading the whole collection —
  /// same reasoning as `AdminBrandProspectsRepository`'s own comment: it can
  /// hold 30k+ docs, not something to pull in full for a report. `brandLeads`
  /// is read in full since it's one-by-one manually-found links, a much
  /// smaller volume.
  BrandOutreachInternSummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandOutreachInternSummariesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandOutreachInternSummariesHash();

  @$internal
  @override
  $FutureProviderElement<List<BrandOutreachInternSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BrandOutreachInternSummary>> create(Ref ref) {
    return brandOutreachInternSummaries(ref);
  }
}

String _$brandOutreachInternSummariesHash() =>
    r'6c778579e050491a3a0faed59608092b23215fcf';

/// The most recent bulk sends across every intern, newest first — which
/// campaign went out, by whom, to how many people, and when. One doc per
/// send (not per recipient), so this is cheap even over a long history.

@ProviderFor(allBrandEmailSends)
final allBrandEmailSendsProvider = AllBrandEmailSendsProvider._();

/// The most recent bulk sends across every intern, newest first — which
/// campaign went out, by whom, to how many people, and when. One doc per
/// send (not per recipient), so this is cheap even over a long history.

final class AllBrandEmailSendsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BrandEmailSend>>,
          List<BrandEmailSend>,
          Stream<List<BrandEmailSend>>
        >
    with
        $FutureModifier<List<BrandEmailSend>>,
        $StreamProvider<List<BrandEmailSend>> {
  /// The most recent bulk sends across every intern, newest first — which
  /// campaign went out, by whom, to how many people, and when. One doc per
  /// send (not per recipient), so this is cheap even over a long history.
  AllBrandEmailSendsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allBrandEmailSendsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allBrandEmailSendsHash();

  @$internal
  @override
  $StreamProviderElement<List<BrandEmailSend>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BrandEmailSend>> create(Ref ref) {
    return allBrandEmailSends(ref);
  }
}

String _$allBrandEmailSendsHash() =>
    r'45c896e4b9af12ed3b8d1e67fce60c22ec1dcfb7';
