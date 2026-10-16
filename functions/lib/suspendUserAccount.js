"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.reinstateUserAccount = exports.suspendUserAccount = void 0;
const auth_1 = require("firebase-admin/auth");
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const adminAuth_1 = require("./shared/adminAuth");
/**
 * Adds or removes the `suspended` custom claim while keeping any other claims
 * the account has. firestore.rules reads `request.auth.token.suspended` to
 * refuse a suspended account's writes (applications, chats, campaigns, ...) —
 * the claim, not the `users.suspended` field, is what the rules can check
 * without an extra read on every request. It only lands in the account's ID
 * token on its next refresh, which `revokeRefreshTokens` forces.
 */
async function setSuspendedClaim(uid, suspended) {
    const auth = (0, auth_1.getAuth)();
    const user = await auth.getUser(uid);
    const claims = { ...(user.customClaims ?? {}) };
    if (suspended) {
        claims.suspended = true;
    }
    else {
        delete claims.suspended;
    }
    await auth.setCustomUserClaims(uid, claims);
}
/**
 * Suspends a Creator or Brand account found violating the Terms of
 * Service. Sign-in itself is deliberately left enabled — the app's own
 * router gate shows a "your account is suspended" screen with nothing
 * reachable except Support, so the person can still see why and get help
 * instead of just hitting a generic sign-in failure. The `suspended` custom
 * claim is what makes that real on the server: firestore.rules refuse the
 * account's writes (except Support) once its token carries the claim, so
 * bypassing the app UI doesn't help. `revokeRefreshTokens` cuts off any
 * already-open session so its next token refresh picks the claim up (an ID
 * token issued before the suspension stays valid for at most an hour).
 */
exports.suspendUserAccount = (0, https_1.onCall)(async (request) => {
    (0, adminAuth_1.requireAdmin)(request);
    const uid = request.data?.uid;
    const reason = request.data?.reason;
    if (!uid) {
        throw new https_1.HttpsError("invalid-argument", "uid is required.");
    }
    await setSuspendedClaim(uid, true);
    await (0, auth_1.getAuth)().revokeRefreshTokens(uid);
    await (0, firestore_1.getFirestore)()
        .collection("users")
        .doc(uid)
        .set({
        suspended: true,
        suspendedReason: reason && reason.length > 0 ? reason : null,
        suspendedAt: firestore_1.Timestamp.now(),
    }, { merge: true });
    return { success: true };
});
/** Reverses `suspendUserAccount` — re-enables sign-in and clears the flag
 * and the claim. Refresh tokens are revoked again so the account's next
 * sign-in gets a token without the claim right away, instead of staying
 * blocked until the old one expires. */
exports.reinstateUserAccount = (0, https_1.onCall)(async (request) => {
    (0, adminAuth_1.requireAdmin)(request);
    const uid = request.data?.uid;
    if (!uid) {
        throw new https_1.HttpsError("invalid-argument", "uid is required.");
    }
    await (0, auth_1.getAuth)().updateUser(uid, { disabled: false });
    await setSuspendedClaim(uid, false);
    await (0, auth_1.getAuth)().revokeRefreshTokens(uid);
    await (0, firestore_1.getFirestore)().collection("users").doc(uid).set({
        suspended: false,
        suspendedReason: null,
    }, { merge: true });
    return { success: true };
});
