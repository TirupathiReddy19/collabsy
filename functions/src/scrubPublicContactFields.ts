import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";

import { requireAdmin } from "./shared/adminAuth";

/**
 * U1 interim mitigation (2026-10-19), ahead of the phase B app release that
 * stops the dual-write for good: strips `email`/`phone`/`fcmToken` off the
 * public `users/{uid}` doc for every account that still has them there.
 * Doesn't touch `private/contact`/`private/phone` — those already hold the
 * same data, correctly access-controlled.
 *
 * Not a permanent fix: build 31 is still live and still dual-writes these
 * fields on sign-in/role-select/phone-change/token-save, so any account
 * that signs in again after this runs gets them rewritten to the public
 * doc. Safe to re-run any time before the phase B build ships and the
 * dual-write is actually removed — each run just re-strips whatever's
 * there again.
 */
export const scrubPublicContactFields = onCall(async (request) => {
  requireAdmin(request);

  const firestore = getFirestore();
  let scanned = 0;
  let scrubbed = 0;
  let pageToken: FirebaseFirestore.QueryDocumentSnapshot | undefined;

  do {
    let query = firestore.collection("users").orderBy("__name__").limit(500);
    if (pageToken) query = query.startAfter(pageToken);
    const page = await query.get();
    if (page.empty) break;

    let batch = firestore.batch();
    for (const doc of page.docs) {
      scanned++;
      const data = doc.data();
      const hasAny =
        "email" in data || "phone" in data || "fcmToken" in data;
      if (!hasAny) continue;

      const update: Record<string, FieldValue> = {};
      if ("email" in data) update.email = FieldValue.delete();
      if ("phone" in data) update.phone = FieldValue.delete();
      if ("fcmToken" in data) update.fcmToken = FieldValue.delete();
      batch.update(doc.ref, update);
      scrubbed++;
    }
    await batch.commit();
    pageToken = page.docs[page.docs.length - 1];
  } while (true);

  return { scanned, scrubbed };
});
