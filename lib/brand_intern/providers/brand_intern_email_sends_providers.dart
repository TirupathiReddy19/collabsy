import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../shared/models/brand_email_send.dart';

part 'brand_intern_email_sends_providers.g.dart';

BrandEmailSend _emailSendFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;
  final sentAt = data['sentAt'];
  return (
    id: doc.id,
    internId: data['internId'] as String? ?? '',
    internEmail: data['internEmail'] as String? ?? '',
    type: data['type'] as String? ?? 'bulk',
    campaignId: data['campaignId'] as String?,
    campaignName: data['campaignName'] as String? ?? 'Custom message',
    subject: data['subject'] as String? ?? '',
    recipientCount: data['recipientCount'] as int? ?? 0,
    sentAt: sentAt is Timestamp ? sentAt.toDate() : null,
  );
}

/// This intern's own bulk-send history, most recent first — shown in the
/// Dashboard tab. `sendBrandProspectMassEmail` is the only writer.
@riverpod
Stream<List<BrandEmailSend>> myBrandEmailSends(Ref ref) {
  final uid = ref.watch(authRepositoryProvider).currentUser?.uid;
  if (uid == null) return Stream.value(const []);
  return ref
      .watch(firestoreProvider)
      .collection('brandEmailSends')
      .where('internId', isEqualTo: uid)
      .orderBy('sentAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(_emailSendFromDoc).toList());
}
