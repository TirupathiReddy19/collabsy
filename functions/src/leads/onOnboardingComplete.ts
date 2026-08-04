import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions";

import { matchBrandLeadToBrand } from "../brandLeads/brandLeadsHelpers";

async function stampOnboardingComplete(
  collection: string,
  uid: string
): Promise<void> {
  const firestore = getFirestore();
  const matches = await firestore
    .collection(collection)
    .where("matchedUid", "==", uid)
    .get();
  if (matches.empty) return;

  const batch = firestore.batch();
  for (const doc of matches.docs) {
    batch.set(
      doc.ref,
      {
        status: "onboardingComplete",
        onboardingCompleteAt: Timestamp.now(),
      },
      { merge: true }
    );
  }
  await batch.commit();
}

/**
 * Final stage of both outreach funnels (linkGenerated -> clicked ->
 * signedUp -> onboardingComplete). `matchLeadToCreator` (called from
 * `saveProfile` at Instagram-connect time) already stamped `matchedUid` on
 * any `leads` doc this user matched — once their
 * `users/{uid}.onboardingCompleted` flips to true, stamp that same lead as
 * fully onboarded.
 *
 * For `brandLeads`, the equivalent match happens on a `brandProfiles`
 * write (`onBrandProfileWritten`), a separate trigger from this one — since
 * the two can fire in either order relative to each other, this also
 * re-derives the match here from the brand's current `linkedinUrl` before
 * sweeping, so attribution is correct regardless of which trigger's write
 * lands first.
 */
export const onOnboardingComplete = onDocumentUpdated(
  "users/{uid}",
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!before || !after) return;
    if (before.onboardingCompleted === true) return;
    if (after.onboardingCompleted !== true) return;

    const uid = event.params.uid;
    const firestore = getFirestore();

    try {
      await stampOnboardingComplete("leads", uid);
    } catch (error) {
      logger.error("Failed to stamp lead onboardingComplete", error);
    }

    try {
      const brandProfileDoc = await firestore
        .collection("brandProfiles")
        .doc(uid)
        .get();
      const linkedinUrl = brandProfileDoc.data()?.linkedinUrl as
        | string
        | undefined;
      if (linkedinUrl) {
        await matchBrandLeadToBrand(linkedinUrl, uid);
      }
      await stampOnboardingComplete("brandLeads", uid);
    } catch (error) {
      logger.error("Failed to stamp brand lead onboardingComplete", error);
    }
  }
);
