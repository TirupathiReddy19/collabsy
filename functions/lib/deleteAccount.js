"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteAccount = void 0;
const auth_1 = require("firebase-admin/auth");
const firestore_1 = require("firebase-admin/firestore");
const storage_1 = require("firebase-admin/storage");
const https_1 = require("firebase-functions/v2/https");
const firebase_functions_1 = require("firebase-functions");
/**
 * Deletes the caller's own account — the in-app path Apple's App Store
 * guideline 5.1.1(v) requires for any app that supports account creation.
 * Uses the Admin SDK throughout, so unlike a client-side `user.delete()`
 * there's no `requires-recent-login` constraint to work around.
 *
 * Deliberately scoped to the user's own directly-owned documents —
 * `campaigns`, `applications`, `chats`/`chatMessages`, and `supportChats`
 * are left untouched, since hard-deleting those would corrupt the other
 * party's (Brand/Creator/support) legitimate history. `Promise.allSettled`
 * so a doc/file that doesn't exist for this account (e.g. a Brand has no
 * `instagram_accounts` doc) doesn't abort the rest.
 */
exports.deleteAccount = (0, https_1.onCall)(async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
        throw new https_1.HttpsError("unauthenticated", "Sign in required.");
    }
    const firestore = (0, firestore_1.getFirestore)();
    const bucket = (0, storage_1.getStorage)().bucket();
    const results = await Promise.allSettled([
        bucket.file(`avatars/${uid}`).delete(),
        bucket.file(`instagram-avatars/${uid}.jpg`).delete(),
        firestore.collection("users").doc(uid).delete(),
        firestore.collection("creatorProfiles").doc(uid).delete(),
        firestore.collection("brandProfiles").doc(uid).delete(),
        firestore
            .collection("instagram_accounts")
            .doc(uid)
            .collection("private")
            .doc("tokens")
            .delete(),
        firestore.collection("instagram_accounts").doc(uid).delete(),
        firestore.collection("announcementReads").doc(uid).delete(),
    ]);
    for (const result of results) {
        if (result.status === "rejected") {
            firebase_functions_1.logger.error("deleteAccount cleanup step failed", result.reason);
        }
    }
    await (0, auth_1.getAuth)().deleteUser(uid);
    return { success: true };
});
