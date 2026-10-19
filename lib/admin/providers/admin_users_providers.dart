import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../features/auth/models/app_user_profile.dart';
import '../../features/auth/providers/auth_providers.dart';
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

/// Every [role]'s email/phone in one go, keyed by uid — backs the admin
/// Creators/Brands screens' search and CSV export now that U1 phase B
/// removed the public `email`/`phone` fields those used to read directly.
/// Keyed by [UserRole] rather than the actual id list (a fresh `List`
/// built on every build() is never `==` to the last one, so a family
/// keyed by it would never hit cache) — refetches whenever the underlying
/// user list changes.
@riverpod
Future<Map<String, Map<String, dynamic>>> privateContactsByRole(
  Ref ref,
  UserRole role,
) async {
  final users = await ref.watch(usersByRoleProvider(role).future);
  return ref
      .watch(authRepositoryProvider)
      .fetchPrivateContactsFor(users.map((u) => u.id).toList());
}
