// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_request_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Submits the Brands page's "run it for us" managed-campaign form directly
/// to Firestore — same unauthenticated-public-write shape as
/// `accountDeletionRequests` (see
/// `lib/admin/providers/admin_deletion_requests_providers.dart`), enforced
/// by a strict field-allowlist `create` rule rather than a Cloud Function.

@ProviderFor(CampaignRequestController)
final campaignRequestControllerProvider = CampaignRequestControllerProvider._();

/// Submits the Brands page's "run it for us" managed-campaign form directly
/// to Firestore — same unauthenticated-public-write shape as
/// `accountDeletionRequests` (see
/// `lib/admin/providers/admin_deletion_requests_providers.dart`), enforced
/// by a strict field-allowlist `create` rule rather than a Cloud Function.
final class CampaignRequestControllerProvider
    extends $AsyncNotifierProvider<CampaignRequestController, void> {
  /// Submits the Brands page's "run it for us" managed-campaign form directly
  /// to Firestore — same unauthenticated-public-write shape as
  /// `accountDeletionRequests` (see
  /// `lib/admin/providers/admin_deletion_requests_providers.dart`), enforced
  /// by a strict field-allowlist `create` rule rather than a Cloud Function.
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
    r'10afa54febdade1ebee7c1d6ff3f776ac556a56f';

/// Submits the Brands page's "run it for us" managed-campaign form directly
/// to Firestore — same unauthenticated-public-write shape as
/// `accountDeletionRequests` (see
/// `lib/admin/providers/admin_deletion_requests_providers.dart`), enforced
/// by a strict field-allowlist `create` rule rather than a Cloud Function.

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
