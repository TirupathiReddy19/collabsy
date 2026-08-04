// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaigns_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(campaignsRepository)
final campaignsRepositoryProvider = CampaignsRepositoryProvider._();

final class CampaignsRepositoryProvider
    extends
        $FunctionalProvider<
          CampaignsRepository,
          CampaignsRepository,
          CampaignsRepository
        >
    with $Provider<CampaignsRepository> {
  CampaignsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'campaignsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$campaignsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CampaignsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CampaignsRepository create(Ref ref) {
    return campaignsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CampaignsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CampaignsRepository>(value),
    );
  }
}

String _$campaignsRepositoryHash() =>
    r'f1292fe51b1196f4dc9d44e3d3dc14c8232aa841';

@ProviderFor(deliverablesRepository)
final deliverablesRepositoryProvider = DeliverablesRepositoryProvider._();

final class DeliverablesRepositoryProvider
    extends
        $FunctionalProvider<
          DeliverablesRepository,
          DeliverablesRepository,
          DeliverablesRepository
        >
    with $Provider<DeliverablesRepository> {
  DeliverablesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliverablesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliverablesRepositoryHash();

  @$internal
  @override
  $ProviderElement<DeliverablesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeliverablesRepository create(Ref ref) {
    return deliverablesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeliverablesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeliverablesRepository>(value),
    );
  }
}

String _$deliverablesRepositoryHash() =>
    r'c4a2086418d44f3e9df0280339f95301a37d56d9';

@ProviderFor(brandCampaigns)
final brandCampaignsProvider = BrandCampaignsProvider._();

final class BrandCampaignsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Campaign>>,
          List<Campaign>,
          Stream<List<Campaign>>
        >
    with $FutureModifier<List<Campaign>>, $StreamProvider<List<Campaign>> {
  BrandCampaignsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandCampaignsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandCampaignsHash();

  @$internal
  @override
  $StreamProviderElement<List<Campaign>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Campaign>> create(Ref ref) {
    return brandCampaigns(ref);
  }
}

String _$brandCampaignsHash() => r'add1badcc66e9a4fe3d7244b3a3ee06dd22deea5';

/// Category/deliverable-type filters for the creator's campaign browse tab.

@ProviderFor(CampaignCategoryFilter)
final campaignCategoryFilterProvider = CampaignCategoryFilterProvider._();

/// Category/deliverable-type filters for the creator's campaign browse tab.
final class CampaignCategoryFilterProvider
    extends $NotifierProvider<CampaignCategoryFilter, String?> {
  /// Category/deliverable-type filters for the creator's campaign browse tab.
  CampaignCategoryFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'campaignCategoryFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$campaignCategoryFilterHash();

  @$internal
  @override
  CampaignCategoryFilter create() => CampaignCategoryFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$campaignCategoryFilterHash() =>
    r'f5523b2b7e375b917d204779473f5db17fdd5463';

/// Category/deliverable-type filters for the creator's campaign browse tab.

abstract class _$CampaignCategoryFilter extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(CampaignDeliverableTypeFilter)
final campaignDeliverableTypeFilterProvider =
    CampaignDeliverableTypeFilterProvider._();

final class CampaignDeliverableTypeFilterProvider
    extends $NotifierProvider<CampaignDeliverableTypeFilter, DeliverableType?> {
  CampaignDeliverableTypeFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'campaignDeliverableTypeFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$campaignDeliverableTypeFilterHash();

  @$internal
  @override
  CampaignDeliverableTypeFilter create() => CampaignDeliverableTypeFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeliverableType? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeliverableType?>(value),
    );
  }
}

String _$campaignDeliverableTypeFilterHash() =>
    r'f86669b9d3d5e6020ec0194de932b891a2cf2c57';

abstract class _$CampaignDeliverableTypeFilter
    extends $Notifier<DeliverableType?> {
  DeliverableType? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DeliverableType?, DeliverableType?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DeliverableType?, DeliverableType?>,
              DeliverableType?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(openCampaigns)
final openCampaignsProvider = OpenCampaignsProvider._();

final class OpenCampaignsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Campaign>>,
          List<Campaign>,
          Stream<List<Campaign>>
        >
    with $FutureModifier<List<Campaign>>, $StreamProvider<List<Campaign>> {
  OpenCampaignsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openCampaignsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openCampaignsHash();

  @$internal
  @override
  $StreamProviderElement<List<Campaign>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Campaign>> create(Ref ref) {
    return openCampaigns(ref);
  }
}

String _$openCampaignsHash() => r'dcd160487e982d9a65bff7640467c98e61010a39';

@ProviderFor(creatorApplications)
final creatorApplicationsProvider = CreatorApplicationsProvider._();

final class CreatorApplicationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CampaignApplication>>,
          List<CampaignApplication>,
          Stream<List<CampaignApplication>>
        >
    with
        $FutureModifier<List<CampaignApplication>>,
        $StreamProvider<List<CampaignApplication>> {
  CreatorApplicationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creatorApplicationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creatorApplicationsHash();

  @$internal
  @override
  $StreamProviderElement<List<CampaignApplication>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CampaignApplication>> create(Ref ref) {
    return creatorApplications(ref);
  }
}

String _$creatorApplicationsHash() =>
    r'c535d630acaa06f33996902faf1a6bee6f240e4e';

/// Every campaign across every brand, sorted newest-first — for the
/// Admin's platform-wide campaigns view.

@ProviderFor(allCampaigns)
final allCampaignsProvider = AllCampaignsProvider._();

/// Every campaign across every brand, sorted newest-first — for the
/// Admin's platform-wide campaigns view.

final class AllCampaignsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Campaign>>,
          List<Campaign>,
          Stream<List<Campaign>>
        >
    with $FutureModifier<List<Campaign>>, $StreamProvider<List<Campaign>> {
  /// Every campaign across every brand, sorted newest-first — for the
  /// Admin's platform-wide campaigns view.
  AllCampaignsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allCampaignsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allCampaignsHash();

  @$internal
  @override
  $StreamProviderElement<List<Campaign>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Campaign>> create(Ref ref) {
    return allCampaigns(ref);
  }
}

String _$allCampaignsHash() => r'69490f7166e617f02c0f984d9f86194044dc4b85';

/// Every application across every campaign and brand — for the Admin's
/// Platform Analytics breakdown.

@ProviderFor(allApplications)
final allApplicationsProvider = AllApplicationsProvider._();

/// Every application across every campaign and brand — for the Admin's
/// Platform Analytics breakdown.

final class AllApplicationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CampaignApplication>>,
          List<CampaignApplication>,
          Stream<List<CampaignApplication>>
        >
    with
        $FutureModifier<List<CampaignApplication>>,
        $StreamProvider<List<CampaignApplication>> {
  /// Every application across every campaign and brand — for the Admin's
  /// Platform Analytics breakdown.
  AllApplicationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allApplicationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allApplicationsHash();

  @$internal
  @override
  $StreamProviderElement<List<CampaignApplication>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CampaignApplication>> create(Ref ref) {
    return allApplications(ref);
  }
}

String _$allApplicationsHash() => r'1a5c3a2402f4fbbeadcf7a8d57178a0fd5791f8c';

@ProviderFor(campaignApplications)
final campaignApplicationsProvider = CampaignApplicationsFamily._();

final class CampaignApplicationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CampaignApplication>>,
          List<CampaignApplication>,
          Stream<List<CampaignApplication>>
        >
    with
        $FutureModifier<List<CampaignApplication>>,
        $StreamProvider<List<CampaignApplication>> {
  CampaignApplicationsProvider._({
    required CampaignApplicationsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'campaignApplicationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$campaignApplicationsHash();

  @override
  String toString() {
    return r'campaignApplicationsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<CampaignApplication>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CampaignApplication>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return campaignApplications(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CampaignApplicationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$campaignApplicationsHash() =>
    r'5dc37f7f08dfab791ece02488ce3a0d9535a3320';

final class CampaignApplicationsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<CampaignApplication>>,
          (String, String)
        > {
  CampaignApplicationsFamily._()
    : super(
        retry: null,
        name: r'campaignApplicationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CampaignApplicationsProvider call(String campaignId, String brandId) =>
      CampaignApplicationsProvider._(
        argument: (campaignId, brandId),
        from: this,
      );

  @override
  String toString() => r'campaignApplicationsProvider';
}

@ProviderFor(campaignById)
final campaignByIdProvider = CampaignByIdFamily._();

final class CampaignByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<Campaign?>,
          Campaign?,
          FutureOr<Campaign?>
        >
    with $FutureModifier<Campaign?>, $FutureProvider<Campaign?> {
  CampaignByIdProvider._({
    required CampaignByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'campaignByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$campaignByIdHash();

  @override
  String toString() {
    return r'campaignByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Campaign?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Campaign?> create(Ref ref) {
    final argument = this.argument as String;
    return campaignById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CampaignByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$campaignByIdHash() => r'099adca5c33c426e03ef76cfd180e7d8bf60e003';

final class CampaignByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Campaign?>, String> {
  CampaignByIdFamily._()
    : super(
        retry: null,
        name: r'campaignByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CampaignByIdProvider call(String campaignId) =>
      CampaignByIdProvider._(argument: campaignId, from: this);

  @override
  String toString() => r'campaignByIdProvider';
}

/// All deliverables for a campaign — the brand's Creators/Overview tabs.

@ProviderFor(campaignDeliverables)
final campaignDeliverablesProvider = CampaignDeliverablesFamily._();

/// All deliverables for a campaign — the brand's Creators/Overview tabs.

final class CampaignDeliverablesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Deliverable>>,
          List<Deliverable>,
          Stream<List<Deliverable>>
        >
    with
        $FutureModifier<List<Deliverable>>,
        $StreamProvider<List<Deliverable>> {
  /// All deliverables for a campaign — the brand's Creators/Overview tabs.
  CampaignDeliverablesProvider._({
    required CampaignDeliverablesFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'campaignDeliverablesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$campaignDeliverablesHash();

  @override
  String toString() {
    return r'campaignDeliverablesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Deliverable>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Deliverable>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return campaignDeliverables(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CampaignDeliverablesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$campaignDeliverablesHash() =>
    r'848219c8084f8bdd362b419e6a60b5b52f6f6b9e';

/// All deliverables for a campaign — the brand's Creators/Overview tabs.

final class CampaignDeliverablesFamily extends $Family
    with
        $FunctionalFamilyOverride<Stream<List<Deliverable>>, (String, String)> {
  CampaignDeliverablesFamily._()
    : super(
        retry: null,
        name: r'campaignDeliverablesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// All deliverables for a campaign — the brand's Creators/Overview tabs.

  CampaignDeliverablesProvider call(String campaignId, String brandId) =>
      CampaignDeliverablesProvider._(
        argument: (campaignId, brandId),
        from: this,
      );

  @override
  String toString() => r'campaignDeliverablesProvider';
}

/// The signed-in creator's own deliverable for an application they were
/// accepted into — null until the brand's acceptance has created it.

@ProviderFor(myDeliverable)
final myDeliverableProvider = MyDeliverableFamily._();

/// The signed-in creator's own deliverable for an application they were
/// accepted into — null until the brand's acceptance has created it.

final class MyDeliverableProvider
    extends
        $FunctionalProvider<
          AsyncValue<Deliverable?>,
          Deliverable?,
          Stream<Deliverable?>
        >
    with $FutureModifier<Deliverable?>, $StreamProvider<Deliverable?> {
  /// The signed-in creator's own deliverable for an application they were
  /// accepted into — null until the brand's acceptance has created it.
  MyDeliverableProvider._({
    required MyDeliverableFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'myDeliverableProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myDeliverableHash();

  @override
  String toString() {
    return r'myDeliverableProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<Deliverable?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Deliverable?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return myDeliverable(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MyDeliverableProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myDeliverableHash() => r'8cde9ac93fef13ee3f19dde0eef26fad05239434';

/// The signed-in creator's own deliverable for an application they were
/// accepted into — null until the brand's acceptance has created it.

final class MyDeliverableFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Deliverable?>, (String, String)> {
  MyDeliverableFamily._()
    : super(
        retry: null,
        name: r'myDeliverableProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The signed-in creator's own deliverable for an application they were
  /// accepted into — null until the brand's acceptance has created it.

  MyDeliverableProvider call(String applicationId, String creatorId) =>
      MyDeliverableProvider._(argument: (applicationId, creatorId), from: this);

  @override
  String toString() => r'myDeliverableProvider';
}

/// Whether the given creator has already applied to a campaign — null
/// means no application yet, so the detail screen can show an Apply button.
/// A live stream so it updates immediately once the application is
/// submitted, without needing to leave and re-enter the screen.

@ProviderFor(myApplication)
final myApplicationProvider = MyApplicationFamily._();

/// Whether the given creator has already applied to a campaign — null
/// means no application yet, so the detail screen can show an Apply button.
/// A live stream so it updates immediately once the application is
/// submitted, without needing to leave and re-enter the screen.

final class MyApplicationProvider
    extends
        $FunctionalProvider<
          AsyncValue<CampaignApplication?>,
          CampaignApplication?,
          Stream<CampaignApplication?>
        >
    with
        $FutureModifier<CampaignApplication?>,
        $StreamProvider<CampaignApplication?> {
  /// Whether the given creator has already applied to a campaign — null
  /// means no application yet, so the detail screen can show an Apply button.
  /// A live stream so it updates immediately once the application is
  /// submitted, without needing to leave and re-enter the screen.
  MyApplicationProvider._({
    required MyApplicationFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'myApplicationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myApplicationHash();

  @override
  String toString() {
    return r'myApplicationProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<CampaignApplication?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<CampaignApplication?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return myApplication(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MyApplicationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myApplicationHash() => r'3ecdee9696dca69b0ee04b7828b468fbbc17efc5';

/// Whether the given creator has already applied to a campaign — null
/// means no application yet, so the detail screen can show an Apply button.
/// A live stream so it updates immediately once the application is
/// submitted, without needing to leave and re-enter the screen.

final class MyApplicationFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<CampaignApplication?>,
          (String, String)
        > {
  MyApplicationFamily._()
    : super(
        retry: null,
        name: r'myApplicationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the given creator has already applied to a campaign — null
  /// means no application yet, so the detail screen can show an Apply button.
  /// A live stream so it updates immediately once the application is
  /// submitted, without needing to leave and re-enter the screen.

  MyApplicationProvider call(String campaignId, String creatorId) =>
      MyApplicationProvider._(argument: (campaignId, creatorId), from: this);

  @override
  String toString() => r'myApplicationProvider';
}

/// Drives campaign creation/status changes and application actions
/// (apply/approve/reject), exposing their loading/error state.

@ProviderFor(CampaignController)
final campaignControllerProvider = CampaignControllerProvider._();

/// Drives campaign creation/status changes and application actions
/// (apply/approve/reject), exposing their loading/error state.
final class CampaignControllerProvider
    extends $AsyncNotifierProvider<CampaignController, void> {
  /// Drives campaign creation/status changes and application actions
  /// (apply/approve/reject), exposing their loading/error state.
  CampaignControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'campaignControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$campaignControllerHash();

  @$internal
  @override
  CampaignController create() => CampaignController();
}

String _$campaignControllerHash() =>
    r'11ba0d6ffd0cafb966279ec788a43af6b768221a';

/// Drives campaign creation/status changes and application actions
/// (apply/approve/reject), exposing their loading/error state.

abstract class _$CampaignController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Drives a creator submitting a deliverable and a brand approving it.

@ProviderFor(DeliverableController)
final deliverableControllerProvider = DeliverableControllerProvider._();

/// Drives a creator submitting a deliverable and a brand approving it.
final class DeliverableControllerProvider
    extends $AsyncNotifierProvider<DeliverableController, void> {
  /// Drives a creator submitting a deliverable and a brand approving it.
  DeliverableControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliverableControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliverableControllerHash();

  @$internal
  @override
  DeliverableController create() => DeliverableController();
}

String _$deliverableControllerHash() =>
    r'b0b860a6c0bae0d1f158ba718ea7b279b0df95d8';

/// Drives a creator submitting a deliverable and a brand approving it.

abstract class _$DeliverableController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
