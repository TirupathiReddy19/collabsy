import { getFirestore } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";

import { requireAdminOrPermission } from "../shared/adminAuth";
import { BRAND_WELCOME, CREATOR_WELCOME, sendWelcomeIfNeeded } from "./sendWelcomeMessage";

/** One-time catch-up for everyone approved before the welcome-message
 * automation existed — the real-time triggers only fire on a *change* to
 * 'approved', so an account that was already approved needs this instead.
 * Safe to run more than once: `sendWelcomeIfNeeded` skips anyone who
 * already has a welcomeMessage notification. */
export const backfillWelcomeMessages = onCall(async (request) => {
  await requireAdminOrPermission(request, "/analytics");

  const db = getFirestore();
  let sent = 0;

  const creators = await db
    .collection("creatorProfiles")
    .where("verificationStatus", "==", "approved")
    .get();
  for (const doc of creators.docs) {
    if (await sendWelcomeIfNeeded(doc.id, "creator", CREATOR_WELCOME)) sent++;
  }

  const brands = await db
    .collection("brandProfiles")
    .where("verificationStatus", "==", "approved")
    .get();
  for (const doc of brands.docs) {
    if (await sendWelcomeIfNeeded(doc.id, "brand", BRAND_WELCOME)) sent++;
  }

  return { sent };
});
