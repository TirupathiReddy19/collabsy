"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteAccount = void 0;
const auth_1 = require("firebase-admin/auth");
const https_1 = require("firebase-functions/v2/https");
const cleanupUserData_1 = require("./cleanupUserData");
/**
 * Deletes the caller's own account — the in-app path Apple's App Store
 * guideline 5.1.1(v) requires for any app that supports account creation.
 * Uses the Admin SDK throughout, so unlike a client-side `user.delete()`
 * there's no `requires-recent-login` constraint to work around.
 *
 * Cleans up Firestore/Storage *before* deleting the Auth user (rather than
 * relying solely on `onAuthUserDeleted`) so this specific, most-common path
 * stays synchronous — the client sees the effect immediately instead of
 * racing a background trigger.
 */
exports.deleteAccount = (0, https_1.onCall)(async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
        throw new https_1.HttpsError("unauthenticated", "Sign in required.");
    }
    await (0, cleanupUserData_1.cleanupUserData)(uid);
    await (0, auth_1.getAuth)().deleteUser(uid);
    return { success: true };
});
