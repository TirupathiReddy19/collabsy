import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";

import {
  markStatus,
  saveMedia,
  saveProfile,
  saveTokens,
} from "./firestoreHelpers";
import { fetchMedia, fetchProfile, refreshLongLivedToken } from "./instagramApiService";

/** Runs daily. A long-lived Instagram token is only refreshable *before*
 * it expires — once it lapses, the only fix is a full reconnect — so this
 * proactively refreshes anything expiring within 7 days rather than
 * waiting for a creator to happen to open the app right before the
 * 60-day window runs out. */
export const refreshExpiringInstagramTokens = onSchedule(
  "every 24 hours",
  async () => {
    const firestore = getFirestore();
    const sevenDaysFromNow = Timestamp.fromMillis(
      Date.now() + 7 * 24 * 60 * 60 * 1000
    );

    const snapshot = await firestore
      .collectionGroup("private")
      .where("expiresAt", "<=", sevenDaysFromNow)
      .get();

    for (const doc of snapshot.docs) {
      const userId = doc.ref.parent.parent?.id;
      const accessToken = doc.data().accessToken as string | undefined;
      if (!userId || !accessToken) continue;

      try {
        const refreshed = await refreshLongLivedToken({ accessToken });
        await saveTokens(userId, refreshed);
        const profile = await fetchProfile(refreshed.access_token);
        await saveProfile(userId, profile);
        const media = await fetchMedia(refreshed.access_token);
        await saveMedia(userId, media);
      } catch (error) {
        await markStatus(userId, "expired");
      }
    }
  }
);
