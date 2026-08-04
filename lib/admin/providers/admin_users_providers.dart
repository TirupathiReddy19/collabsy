import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../features/auth/models/app_user_profile.dart';
import '../../shared/models/user_role.dart';

part 'admin_users_providers.g.dart';

/// Every `users` document with the given [role] — the admin-only
/// equivalent of fetching a single profile, but for listing rather than a
/// one-off lookup.
@riverpod
Stream<List<AppUserProfile>> usersByRole(Ref ref, UserRole role) {
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .where('role', isEqualTo: role.toDbValue())
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => AppUserProfile.fromJson({...doc.data(), 'id': doc.id}),
            )
            .toList(),
      );
}
