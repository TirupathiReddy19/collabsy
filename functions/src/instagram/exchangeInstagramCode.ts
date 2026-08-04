import { Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { instagramAppId, instagramAppSecret, instagramRedirectUri } from "./config";
import { saveMedia, saveProfile, saveTokens } from "./firestoreHelpers";
import {
  InstagramApiError,
  exchangeCodeForShortLivedToken,
  exchangeForLongLivedToken,
  fetchMedia,
  fetchProfile,
} from "./instagramApiService";

/** Callable from Flutter with `{ code }` — the authorization code from the
 * OAuth redirect. Does the full short-lived -> long-lived token exchange
 * and the initial profile/media sync entirely server-side; the App Secret
 * this requires (via the `instagramAppSecret` param) never leaves this
 * function. */
export const exchangeInstagramCode = onCall(
  { secrets: [instagramAppSecret] },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }

    const code = request.data?.code;
    if (typeof code !== "string" || code.length === 0) {
      throw new HttpsError("invalid-argument", "Missing authorization code.");
    }

    try {
      const shortLived = await exchangeCodeForShortLivedToken({
        appId: instagramAppId.value(),
        appSecret: instagramAppSecret.value(),
        code,
        redirectUri: instagramRedirectUri.value(),
      });

      const longLived = await exchangeForLongLivedToken({
        appSecret: instagramAppSecret.value(),
        shortLivedToken: shortLived.access_token,
      });
      await saveTokens(uid, longLived);

      const profile = await fetchProfile(longLived.access_token);
      await saveProfile(uid, profile, { connectedAt: Timestamp.now() });

      const media = await fetchMedia(longLived.access_token);
      await saveMedia(uid, media);

      return { success: true };
    } catch (error) {
      if (error instanceof InstagramApiError) {
        throw new HttpsError("failed-precondition", error.message, {
          reason: "token-invalid",
        });
      }
      throw new HttpsError("internal", "Failed to connect Instagram.");
    }
  }
);
