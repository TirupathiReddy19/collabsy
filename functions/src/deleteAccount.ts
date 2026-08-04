import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";

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
export const deleteAccount = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const firestore = getFirestore();
  const bucket = getStorage().bucket();

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
      logger.error("deleteAccount cleanup step failed", result.reason);
    }
  }

  await getAuth().deleteUser(uid);
  return { success: true };
});
