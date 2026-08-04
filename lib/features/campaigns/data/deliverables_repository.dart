import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/deliverable.dart';
import '../models/deliverable_status.dart';

/// The only place in the `campaigns` feature that talks to the
/// `deliverables` Firestore collection directly. Same composite-index
/// avoidance philosophy as [CampaignsRepository] — every query here filters
/// on two plain equality fields and nothing else.
class DeliverablesRepository {
  DeliverablesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _deliverables =>
      _firestore.collection('deliverables');

  /// Deterministic ID so accepting the same application twice (e.g. a
  /// retried tap, or the brand screen's backfill `ref.listen` re-firing on
  /// every applications snapshot) can't create a second deliverable doc for
  /// it — checked explicitly rather than `set(..., merge: true)`, since a
  /// merge would still overwrite `status` back to `pending` on top of a
  /// creator's already-submitted or brand-approved deliverable.
  ///
  /// The existence check is a QUERY (not a direct `.doc(id).get()`) — a
  /// speculative get on a document that might not exist yet fails the
  /// security rule (`resource` is null server-side, so `resource.data.X`
  /// throws and the read is denied outright), the same class of issue as
  /// every other existence check in this codebase.
  Future<void> createForApplication({
    required String applicationId,
    required String campaignId,
    required String creatorId,
    required String creatorName,
    required String brandId,
  }) async {
    final existing = await _deliverables
        .where('applicationId', isEqualTo: applicationId)
        .where('brandId', isEqualTo: brandId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;
    await _deliverables.doc(applicationId).set({
      'campaignId': campaignId,
      'applicationId': applicationId,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'brandId': brandId,
      'status': DeliverableStatus.pending.toDbValue(),
    });
  }

  Stream<List<Deliverable>> watchForCampaign({
    required String campaignId,
    required String brandId,
  }) {
    return _deliverables
        .where('campaignId', isEqualTo: campaignId)
        .where('brandId', isEqualTo: brandId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Deliverable.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  Stream<Deliverable?> watchForApplication({
    required String applicationId,
    required String creatorId,
  }) {
    return _deliverables
        .where('applicationId', isEqualTo: applicationId)
        .where('creatorId', isEqualTo: creatorId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          return Deliverable.fromJson({...doc.data(), 'id': doc.id});
        });
  }

  Future<void> submit({
    required String deliverableId,
    required String submissionNote,
  }) {
    return _deliverables.doc(deliverableId).update({
      'status': DeliverableStatus.submitted.toDbValue(),
      'submissionNote': submissionNote,
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> approve({required String deliverableId}) {
    return _deliverables.doc(deliverableId).update({
      'status': DeliverableStatus.approved.toDbValue(),
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }
}
