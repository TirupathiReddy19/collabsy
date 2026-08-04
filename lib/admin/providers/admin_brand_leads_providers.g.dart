// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_brand_leads_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every brand outreach lead across every intern, newest first — the Admin
/// portal's Brand Outreach Leads screen. Interns only ever see their own
/// (see `brand_intern/providers/brand_intern_leads_providers.dart`'s
/// `watchMine`); this is the cross-intern tracking view. Mirrors
/// `admin_leads_providers.dart` exactly.

@ProviderFor(allBrandLeads)
final allBrandLeadsProvider = AllBrandLeadsProvider._();

/// Every brand outreach lead across every intern, newest first — the Admin
/// portal's Brand Outreach Leads screen. Interns only ever see their own
/// (see `brand_intern/providers/brand_intern_leads_providers.dart`'s
/// `watchMine`); this is the cross-intern tracking view. Mirrors
/// `admin_leads_providers.dart` exactly.

final class AllBrandLeadsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BrandLead>>,
          List<BrandLead>,
          Stream<List<BrandLead>>
        >
    with $FutureModifier<List<BrandLead>>, $StreamProvider<List<BrandLead>> {
  /// Every brand outreach lead across every intern, newest first — the Admin
  /// portal's Brand Outreach Leads screen. Interns only ever see their own
  /// (see `brand_intern/providers/brand_intern_leads_providers.dart`'s
  /// `watchMine`); this is the cross-intern tracking view. Mirrors
  /// `admin_leads_providers.dart` exactly.
  AllBrandLeadsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allBrandLeadsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allBrandLeadsHash();

  @$internal
  @override
  $StreamProviderElement<List<BrandLead>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BrandLead>> create(Ref ref) {
    return allBrandLeads(ref);
  }
}

String _$allBrandLeadsHash() => r'cef901e862024fb03855a4d97f4de2b0f2c61998';
