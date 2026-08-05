import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { logger } from "firebase-functions";

/**
 * Deletes every Firestore doc/Storage file owned by `uid` — shared between
 * `deleteAccount` (the in-app self-service path) and `onAuthUserDeleted`
 * (a safety net for every *other* way an Auth user can disappear: deleted
 * straight from the Firebase Console, via the Admin SDK, etc.). Console
 * deletions in particular never touch Firestore at all, which is exactly
 * how creators kept showing up in Discover/Admin after being "deleted" —
 * this is what actually closes that gap, regardless of how the Auth user
 * went away.
 *
 * Deliberately scoped to the user's own directly-owned documents — see
 * `deleteAccount`'s doc comment for why `campaigns`/`applications`/
 * `chats`/`supportChats` are left untouched. Idempotent: safe to call
 * twice (e.g. once from `deleteAccount`, once from the trigger it causes)
 * since deleting an already-deleted doc is a no-op, not an error.
 */
export async function cleanupUserData(uid: string): Promise<void> {
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
      logger.error("cleanupUserData step failed", result.reason);
    }
  }
}
