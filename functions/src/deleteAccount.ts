import { getAuth } from "firebase-admin/auth";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { cleanupUserData } from "./cleanupUserData";

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
export const deleteAccount = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  await cleanupUserData(uid);
  await getAuth().deleteUser(uid);
  return { success: true };
});
