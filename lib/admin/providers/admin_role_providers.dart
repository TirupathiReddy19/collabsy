import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../models/staff_account.dart';

part 'admin_role_providers.g.dart';

/// The only place that writes to `staffAccounts` or calls the account
/// -creation Cloud Function — matches `AdminAuditLogRepository`'s "one
/// repository per collection" convention.
class AdminRoleRepository {
  AdminRoleRepository(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  /// Creates a new staff login — the client SDK can't create a Firebase
  /// Auth user without signing out the caller's own session, so this goes
  /// through `createStaffAccount` (Admin SDK, admin-only gated server-side).
  Future<void> createStaffAccount({
    required String email,
    required String password,
    required String roleName,
    required Map<String, bool> permissions,
  }) {
    return _functions.httpsCallable('createStaffAccount').call({
      'email': email,
      'password': password,
      'roleName': roleName,
      'permissions': permissions,
    });
  }

  Future<void> setActive(String uid, bool active) {
    return _firestore.collection('staffAccounts').doc(uid).update({
      'active': active,
    });
  }

  /// Reads each account's real last-sign-in time straight from Firebase
  /// Auth (via `getStaffLastSignIn`) rather than a Firestore field kept in
  /// sync — Auth's own metadata is the source of truth, so there's nothing
  /// to go stale.
  Future<Map<String, DateTime?>> fetchLastSignIn(List<String> uids) async {
    final result = await _functions.httpsCallable('getStaffLastSignIn').call({
      'uids': uids,
    });
    final data = Map<String, dynamic>.from(result.data as Map);
    return data.map(
      (uid, iso) =>
          MapEntry(uid, iso == null ? null : DateTime.parse(iso as String)),
    );
  }

  /// Invalidates a staff account's active session(s) immediately — unlike
  /// `setActive(false)`, which only blocks the *next* sign-in/route check,
  /// this revokes tokens already issued.
  Future<void> forceLogout(String uid) {
    return _functions.httpsCallable('forceLogoutStaffAccount').call({
      'uid': uid,
    });
  }

  /// Lets an existing staff account's access be revised later — e.g.
  /// granting it a sidebar section that didn't exist yet when the role was
  /// first created. Plain Firestore write, no Cloud Function needed (unlike
  /// creation, this never touches Firebase Auth).
  Future<void> updatePermissions(String uid, Map<String, bool> permissions) {
    return _firestore.collection('staffAccounts').doc(uid).update({
      'permissions': permissions,
    });
  }
}

@Riverpod(keepAlive: true)
AdminRoleRepository adminRoleRepository(Ref ref) {
  return AdminRoleRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseFunctionsProvider),
  );
}

@riverpod
Stream<List<StaffAccount>> allStaffAccounts(Ref ref) {
  return ref
      .watch(firestoreProvider)
      .collection('staffAccounts')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          final createdAt = data['createdAt'];
          return (
            uid: doc.id,
            email: data['email'] as String? ?? '',
            roleName: data['roleName'] as String? ?? '',
            permissions: Map<String, bool>.from(
              (data['permissions'] as Map?) ?? const {},
            ),
            active: data['active'] as bool? ?? false,
            createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
          );
        }).toList()..sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );
      });
}

/// Last-sign-in time per staff uid — re-fetched whenever the staff list
/// changes (e.g. a new account is created).
@riverpod
Future<Map<String, DateTime?>> staffLastSignIn(Ref ref) async {
  final accounts = await ref.watch(allStaffAccountsProvider.future);
  if (accounts.isEmpty) return {};
  return ref
      .watch(adminRoleRepositoryProvider)
      .fetchLastSignIn(accounts.map((a) => a.uid).toList());
}
