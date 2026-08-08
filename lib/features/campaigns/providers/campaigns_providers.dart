import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/firebase_service.dart';
import '../../../shared/utils/creator_display_name.dart';
import '../../auth/providers/auth_providers.dart';
import '../../brand/providers/brand_profile_providers.dart';
import '../../settings/providers/instagram_providers.dart';
import '../data/campaigns_repository.dart';
import '../data/deliverables_repository.dart';
import '../models/application_status.dart';
import '../models/campaign.dart';
import '../models/campaign_application.dart';
import '../models/campaign_status.dart';
import '../models/compensation_type.dart';
import '../models/deliverable.dart';
import '../models/deliverable_type.dart';
import '../../notifications/models/notification_type.dart';
import '../../notifications/providers/notifications_providers.dart';

part 'campaigns_providers.g.dart';

@Riverpod(keepAlive: true)
CampaignsRepository campaignsRepository(Ref ref) {
  return CampaignsRepository(ref.watch(firestoreProvider));
}

@Riverpod(keepAlive: true)
DeliverablesRepository deliverablesRepository(Ref ref) {
  return DeliverablesRepository(ref.watch(firestoreProvider));
}

// Reads the user from authStateChangesProvider rather than
// authRepositoryProvider.currentUser — the latter is a plain getter, so
// watching it doesn't rebuild this provider when auth state actually
// changes, locking in whatever currentUser was the first time something
// read this provider for the rest of the app session.
@Riverpod(keepAlive: true)
Stream<List<Campaign>> brandCampaigns(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(campaignsRepositoryProvider).watchBrandCampaigns(user.uid);
}

/// Category/deliverable-type filters for the creator's campaign browse tab.
@Riverpod(keepAlive: true)
class CampaignCategoryFilter extends _$CampaignCategoryFilter {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

@Riverpod(keepAlive: true)
class CampaignDeliverableTypeFilter extends _$CampaignDeliverableTypeFilter {
  @override
  DeliverableType? build() => null;

  void set(DeliverableType? value) => state = value;
}

@Riverpod(keepAlive: true)
Stream<List<Campaign>> openCampaigns(Ref ref) {
  final category = ref.watch(campaignCategoryFilterProvider);
  final deliverableType = ref.watch(campaignDeliverableTypeFilterProvider);
  return ref
      .watch(campaignsRepositoryProvider)
      .watchOpenCampaigns(deliverableType: deliverableType)
      .map((campaigns) {
        // Belt-and-suspenders with the `expireCampaigns` scheduled Cloud
        // Function, which flips `status` away from `active` once `endDate`
        // passes but only runs every 24 hours — this catches a campaign the
        // moment it expires instead of leaving it visible for up to a day.
        final notExpired = campaigns
            .where((campaign) => !campaign.isExpired)
            .toList();
        final filtered = category == null
            ? notExpired
            : notExpired
                  .where((campaign) => campaign.categories.contains(category))
                  .toList();
        return [...filtered]..sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );
      });
}

@Riverpod(keepAlive: true)
Stream<List<CampaignApplication>> creatorApplications(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(const []);
  return ref
      .watch(campaignsRepositoryProvider)
      .watchCreatorApplications(user.uid);
}

/// Every campaign across every brand, sorted newest-first — for the
/// Admin's platform-wide campaigns view.
@Riverpod(keepAlive: true)
Stream<List<Campaign>> allCampaigns(Ref ref) {
  return ref.watch(campaignsRepositoryProvider).watchAllCampaigns().map((
    campaigns,
  ) {
    return [...campaigns]..sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
  });
}

/// Every application across every campaign and brand — for the Admin's
/// Platform Analytics breakdown.
@Riverpod(keepAlive: true)
Stream<List<CampaignApplication>> allApplications(Ref ref) {
  return ref.watch(campaignsRepositoryProvider).watchAllApplications();
}

@riverpod
Stream<List<CampaignApplication>> campaignApplications(
  Ref ref,
  String campaignId,
  String brandId,
) {
  return ref
      .watch(campaignsRepositoryProvider)
      .watchApplicationsForCampaign(campaignId: campaignId, brandId: brandId);
}

@riverpod
Future<Campaign?> campaignById(Ref ref, String campaignId) {
  return ref.watch(campaignsRepositoryProvider).fetchCampaign(campaignId);
}

/// All deliverables for a campaign — the brand's Creators/Overview tabs.
@riverpod
Stream<List<Deliverable>> campaignDeliverables(
  Ref ref,
  String campaignId,
  String brandId,
) {
  return ref
      .watch(deliverablesRepositoryProvider)
      .watchForCampaign(campaignId: campaignId, brandId: brandId);
}

/// The signed-in creator's own deliverable for an application they were
/// accepted into — null until the brand's acceptance has created it.
@riverpod
Stream<Deliverable?> myDeliverable(
  Ref ref,
  String applicationId,
  String creatorId,
) {
  return ref
      .watch(deliverablesRepositoryProvider)
      .watchForApplication(applicationId: applicationId, creatorId: creatorId);
}

/// Whether the given creator has already applied to a campaign — null
/// means no application yet, so the detail screen can show an Apply button.
/// A live stream so it updates immediately once the application is
/// submitted, without needing to leave and re-enter the screen.
@riverpod
Stream<CampaignApplication?> myApplication(
  Ref ref,
  String campaignId,
  String creatorId,
) {
  return ref
      .watch(campaignsRepositoryProvider)
      .watchApplication(campaignId: campaignId, creatorId: creatorId);
}

/// Drives campaign creation/status changes and application actions
/// (apply/approve/reject), exposing their loading/error state.
@Riverpod(keepAlive: true)
class CampaignController extends _$CampaignController {
  @override
  FutureOr<void> build() {}

  Future<void> createCampaign({
    required String title,
    required String description,
    required List<String> categories,
    String? goal,
    required List<String> targetLocations,
    int? minFollowers,
    int? maxFollowers,
    int? creatorsNeeded,
    required DeliverableType deliverableType,
    required int instagramStoryCount,
    required int instagramPostCount,
    required CompensationType compensationType,
    int? budget,
    String? barterDescription,
    String? stateName,
    String? city,
    DateTime? startDate,
    DateTime? endDate,
    required String acceptanceMessage,
    required String rejectionMessage,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      final user = authRepository.currentUser;
      if (user == null) {
        throw StateError('No active session to create a campaign for.');
      }
      final profile = await authRepository.fetchProfile(user.uid);
      final brandProfile = await ref
          .read(brandProfileRepositoryProvider)
          .fetchBrandProfile(user.uid);
      await ref
          .read(campaignsRepositoryProvider)
          .createCampaign(
            brandId: user.uid,
            brandName:
                brandProfile?.companyName ?? profile?.displayName ?? 'Brand',
            title: title,
            description: description,
            categories: categories,
            goal: goal,
            targetLocations: targetLocations,
            minFollowers: minFollowers,
            maxFollowers: maxFollowers,
            creatorsNeeded: creatorsNeeded,
            deliverableType: deliverableType,
            instagramStoryCount: instagramStoryCount,
            instagramPostCount: instagramPostCount,
            compensationType: compensationType,
            budget: budget,
            barterDescription: barterDescription,
            state: stateName,
            city: city,
            startDate: startDate,
            endDate: endDate,
            acceptanceMessage: acceptanceMessage,
            rejectionMessage: rejectionMessage,
          );
    });
  }

  Future<void> updateCampaignStatus({
    required String campaignId,
    required CampaignStatus status,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(campaignsRepositoryProvider)
          .updateCampaignStatus(campaignId: campaignId, status: status),
    );
  }

  Future<void> applyToCampaign({
    required String campaignId,
    required String campaignTitle,
    required String brandId,
    String? agreedDeliverablesSummary,
    int? agreedBudget,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      final user = authRepository.currentUser;
      if (user == null) {
        throw StateError('No active session to apply with.');
      }
      final profile = await authRepository.fetchProfile(user.uid);
      final instagramAccount = await ref
          .read(instagramRepositoryProvider)
          .watchAccount(user.uid)
          .first;
      final creatorName = creatorDisplayName(
        profile?.displayName,
        instagramAccount,
      );
      await ref
          .read(campaignsRepositoryProvider)
          .applyToCampaign(
            campaignId: campaignId,
            campaignTitle: campaignTitle,
            creatorId: user.uid,
            creatorName: creatorName,
            brandId: brandId,
            agreedDeliverablesSummary: agreedDeliverablesSummary,
            agreedBudget: agreedBudget,
          );
      await ref
          .read(notificationsRepositoryProvider)
          .create(
            userId: brandId,
            type: NotificationType.newApplication,
            title: 'New application',
            body: '$creatorName applied to $campaignTitle',
            referenceType: 'campaign',
            referenceId: campaignId,
          );
    });
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(campaignsRepositoryProvider)
          .updateApplicationStatus(
            applicationId: applicationId,
            status: status,
          ),
    );
  }

  /// A creator backing out of their own still-pending application — mirrors
  /// [applyToCampaign]'s shape (repository update + a notification to the
  /// other side) rather than just calling [updateApplicationStatus] bare,
  /// so the brand finds out without needing to notice the status change
  /// on their own.
  Future<void> withdrawApplication({
    required String applicationId,
    required String campaignId,
    required String campaignTitle,
    required String brandId,
    required String creatorName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(campaignsRepositoryProvider)
          .updateApplicationStatus(
            applicationId: applicationId,
            status: ApplicationStatus.withdrawn,
          );
      await ref
          .read(notificationsRepositoryProvider)
          .create(
            userId: brandId,
            type: NotificationType.applicationWithdrawn,
            title: 'Application withdrawn',
            body: '$creatorName withdrew their application to $campaignTitle',
            referenceType: 'campaign',
            referenceId: campaignId,
          );
    });
  }

  /// Passive view-tracking, not a user-initiated action — doesn't touch
  /// [state] (no loading spinner anywhere should depend on this), and swallows
  /// errors since a failed view count shouldn't interrupt browsing.
  Future<void> recordView({
    required String campaignId,
    required String creatorId,
  }) async {
    try {
      await ref
          .read(campaignsRepositoryProvider)
          .recordCampaignView(campaignId: campaignId, creatorId: creatorId);
    } catch (_) {
      // Best-effort — nothing for the caller to react to.
    }
  }
}

/// Drives a creator submitting a deliverable and a brand approving it.
@Riverpod(keepAlive: true)
class DeliverableController extends _$DeliverableController {
  @override
  FutureOr<void> build() {}

  Future<void> submit({
    required String deliverableId,
    required String submissionNote,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(deliverablesRepositoryProvider)
          .submit(deliverableId: deliverableId, submissionNote: submissionNote),
    );
  }

  Future<void> approve({required String deliverableId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(deliverablesRepositoryProvider)
          .approve(deliverableId: deliverableId),
    );
  }
}
