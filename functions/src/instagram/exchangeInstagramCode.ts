import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { instagramAppId, instagramAppSecret, instagramRedirectUri } from "./config";
import { saveProfile, saveTokens } from "./firestoreHelpers";
import {
  InstagramApiError,
  exchangeCodeForShortLivedToken,
  exchangeForLongLivedToken,
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

      const profile = await fetchProfile(longLived.access_token);

      // One Instagram account can back only one Collabsy account, otherwise a
      // single creator's followers could vouch for several fake profiles.
      // Checked before anything is stored. An account that was explicitly
      // disconnected has released its claim; connected/expired/revoked ones
      // still hold it until the owner disconnects or deletes the account.
      const holders = await getFirestore()
        .collection("instagram_accounts")
        .where("instagramUserId", "==", profile.id)
        .get();
      const heldByAnother = holders.docs.some(
        (doc) => doc.id !== uid && doc.data().status !== "disconnected"
      );
      if (heldByAnother) {
        throw new HttpsError(
          "already-exists",
          "This Instagram account is already linked to another Collabsy account."
        );
      }

      await saveTokens(uid, longLived);
      await saveProfile(uid, profile, { connectedAt: Timestamp.now() });

      return { success: true };
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      if (error instanceof InstagramApiError) {
        throw new HttpsError("failed-precondition", error.message, {
          reason: "token-invalid",
        });
      }
      throw new HttpsError("internal", "Failed to connect Instagram.");
    }
  }
);
