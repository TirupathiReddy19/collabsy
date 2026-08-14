// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_campaign_requests_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every managed-campaign lead submitted from the public marketing
/// website's Brands page — see `lib/website/widgets/campaign_request_form.dart`.
/// Newest first.

@ProviderFor(allCampaignRequests)
final allCampaignRequestsProvider = AllCampaignRequestsProvider._();

/// Every managed-campaign lead submitted from the public marketing
/// website's Brands page — see `lib/website/widgets/campaign_request_form.dart`.
/// Newest first.

final class AllCampaignRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CampaignRequest>>,
          List<CampaignRequest>,
          Stream<List<CampaignRequest>>
        >
    with
        $FutureModifier<List<CampaignRequest>>,
        $StreamProvider<List<CampaignRequest>> {
  /// Every managed-campaign lead submitted from the public marketing
  /// website's Brands page — see `lib/website/widgets/campaign_request_form.dart`.
  /// Newest first.
  AllCampaignRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allCampaignRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allCampaignRequestsHash();

  @$internal
  @override
  $StreamProviderElement<List<CampaignRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CampaignRequest>> create(Ref ref) {
    return allCampaignRequests(ref);
  }
}

String _$allCampaignRequestsHash() =>
    r'279a84731e45bf0976038f3647e22107a3ee37d0';

@ProviderFor(AdminCampaignRequestsController)
final adminCampaignRequestsControllerProvider =
    AdminCampaignRequestsControllerProvider._();

final class AdminCampaignRequestsControllerProvider
    extends $AsyncNotifierProvider<AdminCampaignRequestsController, void> {
  AdminCampaignRequestsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminCampaignRequestsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminCampaignRequestsControllerHash();

  @$internal
  @override
  AdminCampaignRequestsController create() => AdminCampaignRequestsController();
}

String _$adminCampaignRequestsControllerHash() =>
    r'2b6debf02fd131fa40857ebfbc744fdae419b5ef';

abstract class _$AdminCampaignRequestsController extends $AsyncNotifier<void> {
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
