import { Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import {
  markStatus,
  saveMedia,
  saveProfile,
  saveTokens,
  tokensDoc,
} from "./firestoreHelpers";
import {
  InstagramApiError,
  fetchMedia,
  fetchProfile,
  refreshLongLivedToken,
} from "./instagramApiService";

const SEVEN_DAYS_MS = 7 * 24 * 60 * 60 * 1000;

/** Manual "Refresh" tap in Connected Accounts — refreshes the long-lived
 * token first if it's within 7 days of expiring, then re-syncs profile +
 * media. Proactive refresh here (rather than only in the scheduled job)
 * means a creator who opens the app right before expiry still gets a
 * fresh 60-day window instead of hitting a stale one. */
export const refreshInstagramMedia = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const tokenSnapshot = await tokensDoc(uid).get();
  const tokenData = tokenSnapshot.data();
  if (!tokenData?.accessToken) {
    throw new HttpsError("failed-precondition", "Instagram isn't connected.", {
      reason: "token-invalid",
    });
  }

  let accessToken: string = tokenData.accessToken;
  const expiresAt =
    (tokenData.expiresAt as Timestamp | undefined)?.toMillis() ?? 0;

  if (expiresAt - Date.now() < SEVEN_DAYS_MS) {
    try {
      const refreshed = await refreshLongLivedToken({ accessToken });
      await saveTokens(uid, refreshed);
      accessToken = refreshed.access_token;
    } catch (error) {
      await markStatus(uid, "expired");
      throw new HttpsError(
        "failed-precondition",
        "Couldn't refresh the connection.",
        { reason: "refresh-failed" }
      );
    }
  }

  try {
    const profile = await fetchProfile(accessToken);
    await saveProfile(uid, profile);
    const media = await fetchMedia(accessToken);
    await saveMedia(uid, media);
    return { success: true };
  } catch (error) {
    if (error instanceof InstagramApiError) {
      await markStatus(uid, "expired");
      throw new HttpsError("failed-precondition", error.message, {
        reason: "token-invalid",
      });
    }
    throw new HttpsError("internal", "Failed to refresh Instagram data.");
  }
});
