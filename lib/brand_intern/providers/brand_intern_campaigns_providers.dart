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
    createdAt: _asDate(data['createdAt']),
    updatedAt: _asDate(data['updatedAt']),
  );
}

/// The only place that talks to the `brandEmailCampaigns` collection —
/// each intern's own saved subject/body templates, picked from a dropdown
/// in the Bulk Email tab instead of retyping the same outreach copy every
/// send.
class BrandInternCampaignsRepository {
  BrandInternCampaignsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<BrandEmailCampaign>> watchMine(String internId) {
    return _firestore
        .collection('brandEmailCampaigns')
        .where('internId', isEqualTo: internId)
        .snapshots()
        .map((snapshot) {
          final campaigns = snapshot.docs.map(_campaignFromDoc).toList()
            ..sort(
              (a, b) => (b.updatedAt ?? DateTime(0)).compareTo(
                a.updatedAt ?? DateTime(0),
              ),
            );
          return campaigns;
        });
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
