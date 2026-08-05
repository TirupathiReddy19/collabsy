"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.reinstateUserAccount = exports.suspendUserAccount = void 0;
const auth_1 = require("firebase-admin/auth");
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const ADMIN_EMAIL = "admin@collabsy.online";
/**
 * Suspends a Creator or Brand account found violating the Terms of
 * Service. Sign-in itself is deliberately left enabled — the app's own
 * router gate is what actually locks a suspended account out (redirects
 * straight to a "your account is suspended" screen with nothing reachable
 * except Support), so the person can still see why and get help instead
 * of just hitting a generic sign-in failure. `revokeRefreshTokens` cuts
 * off any already-open session immediately (same primitive
 * `forceLogoutStaffAccount` uses for staff) so the next thing that
 * session does is re-authenticate and land on that gate too.
 */
exports.suspendUserAccount = (0, https_1.onCall)(async (request) => {
    const email = request.auth?.token?.email;
    if (email !== ADMIN_EMAIL) {
        throw new https_1.HttpsError("permission-denied", "Admin only.");
    }
    const uid = request.data?.uid;
    const reason = request.data?.reason;
    if (!uid) {
        throw new https_1.HttpsError("invalid-argument", "uid is required.");
    }
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
/** Reverses `suspendUserAccount` — re-enables sign-in and clears the flag. */
exports.reinstateUserAccount = (0, https_1.onCall)(async (request) => {
    const email = request.auth?.token?.email;
    if (email !== ADMIN_EMAIL) {
        throw new https_1.HttpsError("permission-denied", "Admin only.");
    }
    const uid = request.data?.uid;
    if (!uid) {
        throw new https_1.HttpsError("invalid-argument", "uid is required.");
    }
    await (0, auth_1.getAuth)().updateUser(uid, { disabled: false });
    await (0, firestore_1.getFirestore)().collection("users").doc(uid).set({
        suspended: false,
        suspendedReason: null,
    }, { merge: true });
    return { success: true };
});
