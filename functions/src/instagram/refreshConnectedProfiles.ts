import { getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { onSchedule } from "firebase-functions/v2/scheduler";

import { saveProfile, tokensDoc } from "./firestoreHelpers";
import { fetchProfile } from "./instagramApiService";

/** Keeps every connected creator's follower/media counts, name, bio, and
 * profile picture reasonably fresh in the background — runs whether or
 * not anyone has the app open, so a Brand looking at a creator's profile
 * always sees recent numbers instead of whatever was true the last time
 * that creator happened to open Connected Accounts. `saveProfile` already
 * stamps `lastSyncedAt`, which is what the "Last synced" line in
 * Connected Accounts reads.
 *
 * Deliberately tolerant of failure: unlike `refreshExpiringInstagramTokens`
 * (whose whole job IS to catch a token that's about to become
 * unrefreshable), a single failed sync here is most likely a transient
 * network/API hiccup — it just logs and moves on to retry in 2 hours,
 * rather than flipping the account to "expired" and kicking the creator
 * back to a "reconnect" state over what might just be a blip. */
export const refreshConnectedInstagramProfiles = onSchedule(
  "every 2 hours",
  async () => {
    const firestore = getFirestore();
    const snapshot = await firestore
      .collection("instagram_accounts")
      .where("status", "==", "connected")
      .get();

    for (const doc of snapshot.docs) {
      const userId = doc.id;
      try {
        const tokenSnapshot = await tokensDoc(userId).get();
        const accessToken = tokenSnapshot.data()?.accessToken as
          | string
          | undefined;
        if (!accessToken) continue;

        const profile = await fetchProfile(accessToken);
        await saveProfile(userId, profile);
      } catch (error) {
        logger.error("Skipped a connected-profile refresh", {
          userId,
          error,
        });
      }
    }
  }
);
