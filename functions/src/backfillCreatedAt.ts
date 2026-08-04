import { getAuth } from "firebase-admin/auth";
import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

const ADMIN_EMAIL = "admin@collabsy.online";

/**
 * One-time admin action: (re)sets `users/{uid}.createdAt` from Firebase
 * Auth's own (real, immutable) `metadata.creationTime` for every account —
 * a bug in `setRole()` meant every password/phone signup never had this
 * field written at all (unlike Google sign-ins), and an earlier client-side
 * stopgap approximated it from `updatedAt` for accounts missing it, which
 * this overwrites with the real value. Only the Admin SDK (server-side,
 * which this function has) can read another user's Auth creation time; the
 * client SDK can only ever see the signed-in user's own.
 */
export const backfillCreatedAtFromAuth = onCall(async (request) => {
  const email = request.auth?.token?.email;
  if (email !== ADMIN_EMAIL) {
    throw new HttpsError("permission-denied", "Admin only.");
  }

  const firestore = getFirestore();
  let updated = 0;
  let pageToken: string | undefined;

  do {
    const page = await getAuth().listUsers(1000, pageToken);
    pageToken = page.pageToken;

    const docs = await Promise.all(
      page.users.map((user) => firestore.collection("users").doc(user.uid).get())
    );

    let batch = firestore.batch();
    let batchCount = 0;
    for (let i = 0; i < page.users.length; i++) {
      const doc = docs[i];
      if (!doc.exists) continue;

      batch.set(
        doc.ref,
        { createdAt: Timestamp.fromDate(new Date(page.users[i].metadata.creationTime)) },
        { merge: true }
      );
      updated++;
      batchCount++;

      if (batchCount === 500) {
        await batch.commit();
        batch = firestore.batch();
        batchCount = 0;
      }
    }
    if (batchCount > 0) await batch.commit();
  } while (pageToken);

  return { updated };
});
