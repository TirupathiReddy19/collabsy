import * as functionsV1 from "firebase-functions/v1";

import { cleanupUserData } from "./cleanupUserData";

/**
 * Safety net for every way an Auth user can disappear *other* than the
 * in-app `deleteAccount` flow — most importantly, deleting a user straight
 * from the Firebase Console (Authentication tab), which only removes the
 * Auth record and never touches Firestore at all. That's exactly how a
 * "deleted" creator kept showing up in Discover and the Admin Creators
 * list — this trigger fires on *any* Auth deletion, regardless of source,
 * and runs the same cleanup `deleteAccount` does. Idempotent, so it's
 * harmless overlap when `deleteAccount` already cleaned up first.
 *
 * Still on the v1 SDK namespace deliberately — `onDelete`/`onCreate`
 * reactive Auth lifecycle triggers haven't been ported to v2; v2's auth
 * triggers (`beforeUserCreated`/`beforeUserSignedIn`) are a different,
 * blocking-function concept and aren't a substitute for this.
 */
export const onAuthUserDeleted = functionsV1.auth.user().onDelete(async (user) => {
  await cleanupUserData(user.uid);
});
