// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_request_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Submits the Brands page's "run it for us" managed-campaign form through
/// the `submitCampaignRequest` Cloud Function, which validates it and limits
/// how often one visitor can send it. It used to write straight to Firestore
/// with an anonymous `create` rule, which nothing stopped a script flooding.
/// The `campaignRequests` doc it produces is unchanged, so the Admin portal
/// reads it as before.

@ProviderFor(CampaignRequestController)
final campaignRequestControllerProvider = CampaignRequestControllerProvider._();

/// Submits the Brands page's "run it for us" managed-campaign form through
/// the `submitCampaignRequest` Cloud Function, which validates it and limits
/// how often one visitor can send it. It used to write straight to Firestore
/// with an anonymous `create` rule, which nothing stopped a script flooding.
/// The `campaignRequests` doc it produces is unchanged, so the Admin portal
/// reads it as before.
final class CampaignRequestControllerProvider
    extends $AsyncNotifierProvider<CampaignRequestController, void> {
  /// Submits the Brands page's "run it for us" managed-campaign form through
  /// the `submitCampaignRequest` Cloud Function, which validates it and limits
  /// how often one visitor can send it. It used to write straight to Firestore
  /// with an anonymous `create` rule, which nothing stopped a script flooding.
  /// The `campaignRequests` doc it produces is unchanged, so the Admin portal
  /// reads it as before.
  CampaignRequestControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'campaignRequestControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$campaignRequestControllerHash();

  @$internal
  @override
  CampaignRequestController create() => CampaignRequestController();
}

String _$campaignRequestControllerHash() =>
    r'35e07502953c3592e787ab3efae25a89d2b08346';

/// Submits the Brands page's "run it for us" managed-campaign form through
/// the `submitCampaignRequest` Cloud Function, which validates it and limits
/// how often one visitor can send it. It used to write straight to Firestore
/// with an anonymous `create` rule, which nothing stopped a script flooding.
/// The `campaignRequests` doc it produces is unchanged, so the Admin portal
/// reads it as before.

abstract class _$CampaignRequestController extends $AsyncNotifier<void> {
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
