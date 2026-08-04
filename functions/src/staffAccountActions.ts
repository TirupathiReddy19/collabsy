import { getAuth } from "firebase-admin/auth";
import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

const ADMIN_EMAIL = "admin@collabsy.online";

/**
 * Reads each staff account's real last-sign-in time from Firebase Auth —
 * the client SDK can only ever see the signed-in user's own
 * `metadata.lastSignInTime`, so surfacing this for other staff accounts on
 * the Role Management screen needs the Admin SDK, same constraint already
 * solved once for `backfillCreatedAtFromAuth`. No Firestore field is kept in
 * sync for this on purpose — Auth's own metadata is the source of truth, so
 * there's nothing to go stale.
 */
export const getStaffLastSignIn = onCall(async (request) => {
  const email = request.auth?.token?.email;
  if (email !== ADMIN_EMAIL) {
    throw new HttpsError("permission-denied", "Admin only.");
  }

  const uids = (request.data?.uids as string[] | undefined) ?? [];
  if (uids.length === 0) return {};

  const result = await getAuth().getUsers(uids.map((uid) => ({ uid })));

  const lastSignIn: Record<string, string | null> = {};
  for (const uid of uids) {
    const user = result.users.find((u) => u.uid === uid);
    lastSignIn[uid] = user?.metadata.lastSignInTime
      ? new Date(user.metadata.lastSignInTime).toISOString()
      : null;
  }
  return lastSignIn;
});

/**
 * Immediately invalidates a staff account's active session(s) — the
 * Active/Inactive switch on Role Management only blocks the *next*
 * sign-in/route check, it doesn't revoke a token that's already been
 * issued. `revokeRefreshTokens` is the standard Admin SDK primitive for
 * this: it invalidates every refresh token issued before now, so the
 * account's current ID token stops being renewable and the next
 * `admin_router.dart` navigation guard check fails.
 *
 * Also writes a `staffLoginEvents` doc (Admin SDK, bypassing rules) so
 * this shows up in that account's own login/logout history — done here,
 * server-side, so it's guaranteed to happen atomically with the actual
 * revoke rather than depending on a follow-up client-side write.
 */
export const forceLogoutStaffAccount = onCall(async (request) => {
  const email = request.auth?.token?.email;
  if (email !== ADMIN_EMAIL) {
    throw new HttpsError("permission-denied", "Admin only.");
  }

  const uid = request.data?.uid as string | undefined;
  if (!uid) {
    throw new HttpsError("invalid-argument", "uid is required.");
  }

  await getAuth().revokeRefreshTokens(uid);

  const staffDoc = await getFirestore().collection("staffAccounts").doc(uid).get();
  const staffData = staffDoc.data();
  await getFirestore().collection("staffLoginEvents").add({
    uid,
    email: staffData?.email ?? "",
    roleName: staffData?.roleName ?? "",
    type: "forcedLogout",
    timestamp: Timestamp.now(),
  });

  return { success: true };
});
