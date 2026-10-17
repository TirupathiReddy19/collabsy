import { getFirestore } from "firebase-admin/firestore";

/**
 * U1 phase A: fcmToken is moving from the public `users/{uid}` doc to
 * `users/{uid}/private/contact`, written by both locations during the
 * transition (AuthRepository dual-writes; backfillPrivateContact covers
 * existing accounts). Reads the new location first and falls back to the
 * old public field — covers the narrow window on a freshly-updated account
 * before the backfill has run, or before this account's own device has
 * triggered a fresh token write. Safe to drop once phase B removes the
 * public field for good.
 */
export async function getFcmToken(uid: string): Promise<string | undefined> {
  const firestore = getFirestore();
  const privateDoc = await firestore
    .collection("users")
    .doc(uid)
    .collection("private")
    .doc("contact")
    .get();
  const privateToken = privateDoc.data()?.fcmToken as string | undefined;
  if (privateToken) return privateToken;

  const publicDoc = await firestore.collection("users").doc(uid).get();
  return publicDoc.data()?.fcmToken as string | undefined;
}
