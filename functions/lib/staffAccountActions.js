"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.forceLogoutStaffAccount = exports.getStaffLastSignIn = void 0;
const auth_1 = require("firebase-admin/auth");
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
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
exports.getStaffLastSignIn = (0, https_1.onCall)(async (request) => {
    const email = request.auth?.token?.email;
    if (email !== ADMIN_EMAIL) {
        throw new https_1.HttpsError("permission-denied", "Admin only.");
    }
    const uids = request.data?.uids ?? [];
    if (uids.length === 0)
        return {};
    const result = await (0, auth_1.getAuth)().getUsers(uids.map((uid) => ({ uid })));
    const lastSignIn = {};
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
exports.forceLogoutStaffAccount = (0, https_1.onCall)(async (request) => {
    const email = request.auth?.token?.email;
    if (email !== ADMIN_EMAIL) {
        throw new https_1.HttpsError("permission-denied", "Admin only.");
    }
    const uid = request.data?.uid;
    if (!uid) {
        throw new https_1.HttpsError("invalid-argument", "uid is required.");
    }
    await (0, auth_1.getAuth)().revokeRefreshTokens(uid);
    const staffDoc = await (0, firestore_1.getFirestore)().collection("staffAccounts").doc(uid).get();
    const staffData = staffDoc.data();
    await (0, firestore_1.getFirestore)().collection("staffLoginEvents").add({
        uid,
        email: staffData?.email ?? "",
        roleName: staffData?.roleName ?? "",
        type: "forcedLogout",
        timestamp: firestore_1.Timestamp.now(),
    });
    return { success: true };
});
