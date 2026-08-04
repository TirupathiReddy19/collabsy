import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../models/staff_account.dart';

part 'admin_auth_providers.g.dart';

/// The one and only super admin account — matches the email checked
/// server-side in `firestore.rules`' `isAdmin()`. There's no signup path;
/// this account is created once, by hand, in the Firebase Console. Staff
/// accounts created via Role Management (see `StaffAccount`) sign in at the
/// same login screen but are a different, permission-scoped kind of session.
const adminEmail = 'admin@collabsy.online';

/// Whether the currently signed-in Firebase user (if any) is the admin
/// account. Client-side only, for instant UI/redirect purposes — the real
/// enforcement is server-side, in Firestore security rules, which check
/// this same email on every request regardless of what the client claims.
@riverpod
bool isAdmin(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  return user != null && user.email == adminEmail;
}

/// The real signed-in email for whoever is currently using the admin
/// portal — super admin or staff — so audit-log entries attribute to the
/// actual account instead of always saying `adminEmail`.
@riverpod
String? currentAdminEmail(Ref ref) {
  return ref.watch(authStateChangesProvider).value?.email;
}

/// The signed-in staff account's own `staffAccounts` doc, live — `null` for
/// the super admin (unrestricted, no doc exists for them) or when signed
/// out. Used by the sidebar to filter nav items and show the real
/// role/email; NOT used for the router's redirect guard, which needs a
/// one-shot, cached-per-session read instead of a live stream (see
/// admin_router.dart for why).
@riverpod
Stream<StaffAccount?> currentStaffAccount(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null || user.email == adminEmail) return Stream.value(null);
  return ref
      .watch(firestoreProvider)
      .collection('staffAccounts')
      .doc(user.uid)
      .snapshots()
      .map((doc) => _staffAccountFromDoc(doc));
}

StaffAccount? _staffAccountFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  if (!doc.exists) return null;
  final data = doc.data()!;
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
}
