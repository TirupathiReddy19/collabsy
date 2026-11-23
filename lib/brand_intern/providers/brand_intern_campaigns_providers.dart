import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../shared/models/brand_email_campaign.dart';

part 'brand_intern_campaigns_providers.g.dart';

DateTime? _asDate(dynamic value) => value is Timestamp ? value.toDate() : null;

BrandEmailCampaign _campaignFromDoc(
  DocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = doc.data()!;
  return (
    id: doc.id,
    internId: data['internId'] as String? ?? '',
    name: data['name'] as String? ?? '',
    subject: data['subject'] as String? ?? '',
    body: data['body'] as String? ?? '',
    shared: data['shared'] as bool? ?? false,
    createdAt: _asDate(data['createdAt']),
    updatedAt: _asDate(data['updatedAt']),
  );
}

/// The only place that talks to the `brandEmailCampaigns` collection —
/// each intern's own saved subject/body templates, plus any company-wide
/// `shared` ones every intern can use, picked from a dropdown in the Bulk
/// Email tab instead of retyping the same outreach copy every send.
class BrandInternCampaignsRepository {
  BrandInternCampaignsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Own campaigns (`internId == internId`) plus every `shared` one,
  /// combined and kept live. Two separate queries rather than one Firestore
  /// `or()` filter — simpler to reason about, and this collection is small
  /// enough per intern that merging two snapshots client-side costs
  /// nothing. Each source's own [_CombinedCampaigns] slot updates
  /// independently; the combined list is only emitted once both sources
  /// have reported at least once, so the dropdown never flashes
  /// "own-only" before the shared templates arrive a moment later.
  Stream<List<BrandEmailCampaign>> watchMine(String internId) {
    final controller = StreamController<List<BrandEmailCampaign>>.broadcast();
    List<BrandEmailCampaign>? own;
    List<BrandEmailCampaign>? shared;

    void emitIfReady() {
      if (own == null || shared == null) return;
      final combined = [...own!, ...shared!]
        ..sort(
          (a, b) => (b.updatedAt ?? DateTime(0)).compareTo(
            a.updatedAt ?? DateTime(0),
          ),
        );
      controller.add(combined);
    }

    final ownSub = _firestore
        .collection('brandEmailCampaigns')
        .where('internId', isEqualTo: internId)
        .snapshots()
        .listen((snapshot) {
          own = snapshot.docs.map(_campaignFromDoc).toList();
          emitIfReady();
        }, onError: controller.addError);
    final sharedSub = _firestore
        .collection('brandEmailCampaigns')
        .where('shared', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
          shared = snapshot.docs.map(_campaignFromDoc).toList();
          emitIfReady();
        }, onError: controller.addError);

    controller.onCancel = () {
      ownSub.cancel();
      sharedSub.cancel();
    };
    return controller.stream;
  }

  Future<void> create({
    required String internId,
    required String name,
    required String subject,
    required String body,
  }) {
    return _firestore.collection('brandEmailCampaigns').add({
      'internId': internId,
      'name': name,
      'subject': subject,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update({
    required String campaignId,
    required String name,
    required String subject,
    required String body,
  }) {
    return _firestore.collection('brandEmailCampaigns').doc(campaignId).update({
      'name': name,
      'subject': subject,
      'body': body,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String campaignId) {
    return _firestore.collection('brandEmailCampaigns').doc(campaignId).delete();
  }
}

@Riverpod(keepAlive: true)
BrandInternCampaignsRepository brandInternCampaignsRepository(Ref ref) {
  return BrandInternCampaignsRepository(ref.watch(firestoreProvider));
}

@Riverpod(keepAlive: true)
Stream<List<BrandEmailCampaign>> myBrandEmailCampaigns(Ref ref) {
  final uid = ref.watch(authRepositoryProvider).currentUser?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(brandInternCampaignsRepositoryProvider).watchMine(uid);
}
