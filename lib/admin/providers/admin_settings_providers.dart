import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';

part 'admin_settings_providers.g.dart';

const outreachLinksConfigDocId = 'outreachLinks';
const brandOutreachLinksConfigDocId = 'brandOutreachLinks';

/// The only place that reads/writes the `config/{docId}` docs the outreach
/// tools' `redirectLead`/`redirectBrandLead` Cloud Functions depend on
/// (message template, coming-soon toggle, store URLs) — write access is
/// `isAdmin()`-only in `firestore.rules`, so this is exclusively used by
/// the System Settings screen.
class AdminSettingsRepository {
  AdminSettingsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>?> fetchConfig(String docId) async {
    final doc = await _firestore.collection('config').doc(docId).get();
    return doc.data();
  }

  Future<void> updateConfig(String docId, Map<String, dynamic> data) {
    return _firestore
        .collection('config')
        .doc(docId)
        .set(data, SetOptions(merge: true));
  }
}

@Riverpod(keepAlive: true)
AdminSettingsRepository adminSettingsRepository(Ref ref) {
  return AdminSettingsRepository(ref.watch(firestoreProvider));
}

@riverpod
Future<Map<String, dynamic>?> outreachLinksConfig(Ref ref) {
  return ref
      .watch(adminSettingsRepositoryProvider)
      .fetchConfig(outreachLinksConfigDocId);
}

@riverpod
Future<Map<String, dynamic>?> brandOutreachLinksConfig(Ref ref) {
  return ref
      .watch(adminSettingsRepositoryProvider)
      .fetchConfig(brandOutreachLinksConfigDocId);
}
