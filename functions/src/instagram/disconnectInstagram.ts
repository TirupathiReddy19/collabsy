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

  // The app only offers Disconnect once the admin has reviewed the creator,
  // so a profile still awaiting review can't pull its connected account out
  // from under that review (or swap in a different one) by calling this
  // directly.
  const profile = await getFirestore().collection("creatorProfiles").doc(uid).get();
  if (profile.data()?.verificationStatus === "pending") {
    throw new HttpsError(
      "failed-precondition",
      "Instagram can be disconnected once your profile has been reviewed."
    );
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
