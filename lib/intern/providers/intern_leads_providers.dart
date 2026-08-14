import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../shared/models/lead.dart';

part 'intern_leads_providers.g.dart';

DateTime? _asDate(dynamic value) => value is Timestamp ? value.toDate() : null;

Lead _leadFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;
  return (
    handle: doc.id,
    instagramUrl: data['instagramUrl'] as String? ?? '',
    internId: data['internId'] as String? ?? '',
    internEmail: data['internEmail'] as String? ?? '',
    message: data['message'] as String? ?? '',
    comment: data['comment'] as String? ?? 'looking for collabs check your DM.',
    status: data['status'] as String? ?? 'linkGenerated',
    createdAt: _asDate(data['createdAt']),
    clickedAt: _asDate(data['clickedAt']),
    clickCount: data['clickCount'] as int? ?? 0,
    matchedUid: data['matchedUid'] as String?,
    signedUpAt: _asDate(data['signedUpAt']),
    onboardingCompleteAt: _asDate(data['onboardingCompleteAt']),
    internConfirmedSent: data['internConfirmedSent'] as bool? ?? false,
    internConfirmedSentAt: _asDate(data['internConfirmedSentAt']),
    lastFollowUpSentAt: _asDate(data['lastFollowUpSentAt']),
    followUpCount: data['followUpCount'] as int? ?? 0,
  );
}

/// The only place that talks to the `leads`/`config` collections directly.
class InternLeadsRepository {
  InternLeadsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String handle) =>
      _firestore.collection('leads').doc(handle);

  /// Null when no lead exists for this handle yet — the dedup check.
  Future<Lead?> fetch(String handle) async {
    final doc = await _doc(handle).get();
    if (!doc.exists) return null;
    return _leadFromDoc(doc);
  }

  Future<void> create({
    required String handle,
    required String instagramUrl,
    required String internId,
    required String internEmail,
    required String message,
    required String comment,
  }) {
    return _doc(handle).set({
      'instagramHandle': handle,
      'instagramUrl': instagramUrl,
      'internId': internId,
      'internEmail': internEmail,
      'message': message,
      'comment': comment,
      'status': 'linkGenerated',
      'createdAt': FieldValue.serverTimestamp(),
      'clickCount': 0,
      'internConfirmedSent': false,
    });
  }

  /// The intern's one-way "I actually sent this" self-report — see the
  /// timed reveal in `intern_home_screen.dart`'s `_SuccessCard`. Firestore
  /// rules enforce this can only flip false→true, only by the lead's own
  /// creator, and only touches these two fields.
  Future<void> confirmSent(String handle) {
    return _doc(handle).update({
      'internConfirmedSent': true,
      'internConfirmedSentAt': FieldValue.serverTimestamp(),
    });
  }

  /// Logs a follow-up DM the intern says they just sent to a lead that's
  /// still un-clicked or clicked-but-unsigned — same self-report pattern
  /// as [confirmSent]. Unlike that one-way flip, this can happen more
  /// than once per lead (a lead can keep needing follow-up for as long as
  /// it stays stuck), so it increments a counter instead.
  Future<void> logFollowUp(String handle) {
    return _doc(handle).update({
      'lastFollowUpSentAt': FieldValue.serverTimestamp(),
      'followUpCount': FieldValue.increment(1),
    });
  }

  /// Every lead this intern has personally generated, newest first — not
  /// the cross-intern view (that's the Admin portal's Outreach Leads
  /// screen).
  Stream<List<Lead>> watchMine(String internId) {
    return _firestore
        .collection('leads')
        .where('internId', isEqualTo: internId)
        .snapshots()
        .map((snapshot) {
          final leads = snapshot.docs.map(_leadFromDoc).toList()
            ..sort(
              (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
                a.createdAt ?? DateTime(0),
              ),
            );
          return leads;
        });
  }

  Future<Map<String, dynamic>?> fetchConfig() async {
    final doc = await _firestore
        .collection('config')
        .doc('outreachLinks')
        .get();
    return doc.data();
  }
}

@Riverpod(keepAlive: true)
InternLeadsRepository internLeadsRepository(Ref ref) {
  return InternLeadsRepository(ref.watch(firestoreProvider));
}

@Riverpod(keepAlive: true)
Stream<List<Lead>> myLeads(Ref ref) {
  final uid = ref.watch(authRepositoryProvider).currentUser?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(internLeadsRepositoryProvider).watchMine(uid);
}

@riverpod
Future<Map<String, dynamic>?> outreachConfig(Ref ref) {
  return ref.watch(internLeadsRepositoryProvider).fetchConfig();
}
