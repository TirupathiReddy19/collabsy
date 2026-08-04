// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_leads_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every outreach lead across every intern, newest first — the Admin
/// portal's Outreach Leads screen. Interns only ever see their own (see
/// `intern/providers/intern_leads_providers.dart`'s `watchMine`); this is
/// the cross-intern tracking view.

@ProviderFor(allLeads)
final allLeadsProvider = AllLeadsProvider._();

/// Every outreach lead across every intern, newest first — the Admin
/// portal's Outreach Leads screen. Interns only ever see their own (see
/// `intern/providers/intern_leads_providers.dart`'s `watchMine`); this is
/// the cross-intern tracking view.

final class AllLeadsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Lead>>,
          List<Lead>,
          Stream<List<Lead>>
        >
    with $FutureModifier<List<Lead>>, $StreamProvider<List<Lead>> {
  /// Every outreach lead across every intern, newest first — the Admin
  /// portal's Outreach Leads screen. Interns only ever see their own (see
  /// `intern/providers/intern_leads_providers.dart`'s `watchMine`); this is
  /// the cross-intern tracking view.
  AllLeadsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allLeadsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allLeadsHash();

  @$internal
  @override
  $StreamProviderElement<List<Lead>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Lead>> create(Ref ref) {
    return allLeads(ref);
  }
}

String _$allLeadsHash() => r'56e441fe4046ae8260e1688aa44b46996318020e';
