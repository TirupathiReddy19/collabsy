import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { accountDoc, tokensDoc } from "./firestoreHelpers";

/** Deletes the stored token and marks the account disconnected. Also
 * deletes the synced media docs — they're meaningless once disconnected
 * and would otherwise sit stale in Firestore. */
export const disconnectInstagram = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  await tokensDoc(uid)
    .delete()
    .catch(() => undefined);
  await accountDoc(uid).set({ status: "disconnected" }, { merge: true });

  const firestore = getFirestore();
  const mediaSnapshot = await firestore
    .collection("instagram_media")
    .where("userId", "==", uid)
    .get();
  const batch = firestore.batch();
  mediaSnapshot.docs.forEach((doc) => batch.delete(doc.ref));
  await batch.commit();

  return { success: true };
});
