import type { Firestore, Query } from "firebase-admin/firestore";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { logger } from "firebase-functions";

/** Deletes every doc matched by `query`, batching in chunks of 500 (Firestore's per-batch write limit). */
async function deleteMatching(query: Query): Promise<void> {
  const snapshot = await query.get();
  if (snapshot.empty) return;

  const firestore = query.firestore;
  for (let i = 0; i < snapshot.docs.length; i += 500) {
    const batch = firestore.batch();
    for (const doc of snapshot.docs.slice(i, i + 500)) {
      batch.delete(doc.ref);
    }
    await batch.commit();
  }
}

/** Deletes every `campaigns` doc owned by `brandUid`, plus the `applications` filed against them. */
async function cleanupBrandCampaigns(
  firestore: Firestore,
  brandUid: string,
): Promise<void> {
  await deleteMatching(
    firestore.collection("applications").where("brandId", "==", brandUid),
  );
  await deleteMatching(
    firestore.collection("campaigns").where("brandId", "==", brandUid),
  );
}

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
 * A deleted brand's `campaigns` (and the `applications` filed against them)
 * are cascade-deleted too, so they don't keep showing up for creators once
 * the brand behind them is gone. `chats`/`supportChats` are deliberately
 * left untouched — see `deleteAccount`'s doc comment. Idempotent: safe to
 * call twice (e.g. once from `deleteAccount`, once from the trigger it
 * causes) since deleting an already-deleted doc/query match is a no-op,
 * not an error.
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
    cleanupBrandCampaigns(firestore, uid),
  ]);

  for (const result of results) {
    if (result.status === "rejected") {
      logger.error("cleanupUserData step failed", result.reason);
    }
  }
}
