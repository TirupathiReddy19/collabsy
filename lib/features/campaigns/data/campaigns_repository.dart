import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/application_status.dart';
import '../models/campaign.dart';
import '../models/campaign_application.dart';
import '../models/campaign_status.dart';
import '../models/compensation_type.dart';
import '../models/deliverable_type.dart';

/// The only place in the `campaigns` feature that talks to Firestore
/// directly. Deliberately avoids combining `orderBy` with `where` on a
/// different field anywhere here — that needs a composite index configured
/// up front, and campaign/application volumes are small enough for now
/// that sorting client-side (in the providers) is simpler.
class CampaignsRepository {
  CampaignsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _campaigns =>
      _firestore.collection('campaigns');

  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection('applications');

  Future<void> createCampaign({
    required String brandId,
    required String brandName,
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
    String? state,
    String? city,
    DateTime? startDate,
    DateTime? endDate,
    required String acceptanceMessage,
    required String rejectionMessage,
  }) async {
    await _campaigns.add({
      'brandId': brandId,
      'brandName': brandName,
      'title': title,
      'description': description,
      'categories': categories,
      'goal': goal,
      'targetLocations': targetLocations,
      'minFollowers': minFollowers,
      'maxFollowers': maxFollowers,
      'creatorsNeeded': creatorsNeeded,
      'deliverableType': deliverableType.toDbValue(),
      'instagramStoryCount': instagramStoryCount,
      'instagramPostCount': instagramPostCount,
      'compensationType': compensationType.toDbValue(),
      'budget': budget,
      'barterDescription': barterDescription,
      'state': state,
      'city': city,
      if (startDate != null) 'startDate': Timestamp.fromDate(startDate),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate),
      'acceptanceMessage': acceptanceMessage,
      'rejectionMessage': rejectionMessage,
      // Never goes straight to active — an admin has to approve it first
      // (see the campaigns/{campaignId} update rule, which blocks the
      // owning brand from setting status to active themselves).
      'status': CampaignStatus.underReview.toDbValue(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCampaignStatus({
    required String campaignId,
    required CampaignStatus status,
  }) {
    return _campaigns.doc(campaignId).update({'status': status.toDbValue()});
  }

  Stream<List<Campaign>> watchBrandCampaigns(String brandId) {
    return _campaigns
        .where('brandId', isEqualTo: brandId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Campaign.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  /// Category filtering happens client-side (in the provider), not here —
  /// `categories` is a list field, so filtering on it server-side would need
  /// `arrayContains`, which can't combine with the `status` equality filter
  /// above without a Firestore composite index. Campaign volumes are small
  /// enough that filtering after the fact is simpler.
  Stream<List<Campaign>> watchOpenCampaigns({
    DeliverableType? deliverableType,
  }) {
    Query<Map<String, dynamic>> query = _campaigns.where(
      'status',
      isEqualTo: CampaignStatus.active.toDbValue(),
    );
    if (deliverableType != null) {
      query = query.where(
        'deliverableType',
        isEqualTo: deliverableType.toDbValue(),
      );
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Campaign.fromJson({...doc.data(), 'id': doc.id}))
          .toList(),
    );
  }

  /// Every campaign regardless of brand or status — for the Admin's
  /// platform-wide campaigns view. Nothing in the mobile app needs this;
  /// both Creator and Brand screens always scope to a status or a brand.
  Stream<List<Campaign>> watchAllCampaigns() {
    return _campaigns.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Campaign.fromJson({...doc.data(), 'id': doc.id}))
          .toList(),
    );
  }

  Future<Campaign?> fetchCampaign(String campaignId) async {
    final doc = await _campaigns.doc(campaignId).get();
    if (!doc.exists) return null;
    return Campaign.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Every application across every campaign and brand — for the Admin's
  /// Platform Analytics breakdown. Nothing in the mobile app needs this;
  /// Creator/Brand screens always scope to their own id.
  Stream<List<CampaignApplication>> watchAllApplications() {
    return _applications.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) =>
                CampaignApplication.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList(),
    );
  }

  /// Records a creator opening this campaign's detail screen. Fire-and-forget
  /// from the caller's point of view — `viewCount` increments every open,
  /// `viewedByCreatorIds` dedupes automatically via `arrayUnion`. The
  /// security rule allows this specific two-field update from any
  /// authenticated user, not just the owning brand.
  Future<void> recordCampaignView({
    required String campaignId,
    required String creatorId,
  }) {
    return _campaigns.doc(campaignId).update({
      'viewCount': FieldValue.increment(1),
      'viewedByCreatorIds': FieldValue.arrayUnion([creatorId]),
    });
  }

  /// Deterministic ID (`campaignId_creatorId`) so a creator can't apply to
  /// the same campaign twice — applying again just overwrites their
  /// existing application instead of creating a duplicate.
  Future<void> applyToCampaign({
    required String campaignId,
    required String campaignTitle,
    required String creatorId,
    required String creatorName,
    required String brandId,
    String? agreedDeliverablesSummary,
    int? agreedBudget,
  }) async {
    final id = '${campaignId}_$creatorId';
    await _applications.doc(id).set({
      'campaignId': campaignId,
      'campaignTitle': campaignTitle,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'brandId': brandId,
      'status': ApplicationStatus.pending.toDbValue(),
      'appliedAt': FieldValue.serverTimestamp(),
      if (agreedDeliverablesSummary != null)
        'agreedDeliverablesSummary': agreedDeliverablesSummary,
      if (agreedBudget != null) 'agreedBudget': agreedBudget,
    });
  }

  /// Looks this up as a query rather than a direct `.doc(id).get()` —
  /// the security rule can only confirm ownership of a document that
  /// exists, so a speculative "has this creator already applied?" lookup
  /// on an ID that might not exist gets rejected outright. A query
  /// constrained to `creatorId == creatorId` is something the rules
  /// engine can verify up front regardless of whether anything matches.
  ///
  /// A live stream (not a one-shot `.get()`) so the campaign detail screen
  /// updates the instant an application is submitted, instead of showing
  /// the stale "Apply" button until the screen is revisited.
  Stream<CampaignApplication?> watchApplication({
    required String campaignId,
    required String creatorId,
  }) {
    return _applications
        .where('campaignId', isEqualTo: campaignId)
        .where('creatorId', isEqualTo: creatorId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          return CampaignApplication.fromJson({...doc.data(), 'id': doc.id});
        });
  }

  /// [brandId] must be included as an explicit filter (not just
  /// `campaignId`) — Firestore's rules engine rejects a list query outright
  /// unless the query itself is constrained in a way that guarantees every
  /// possible result satisfies the security rule; it can't infer that a
  /// given campaignId only ever belongs to one brand.
  Stream<List<CampaignApplication>> watchApplicationsForCampaign({
    required String campaignId,
    required String brandId,
  }) {
    return _applications
        .where('campaignId', isEqualTo: campaignId)
        .where('brandId', isEqualTo: brandId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    CampaignApplication.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  Stream<List<CampaignApplication>> watchCreatorApplications(String creatorId) {
    return _applications
        .where('creatorId', isEqualTo: creatorId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    CampaignApplication.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
  }) {
    return _applications.doc(applicationId).update({
      'status': status.toDbValue(),
    });
  }
}
