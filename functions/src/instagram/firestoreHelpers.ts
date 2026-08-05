import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { logger } from "firebase-functions";

import { matchLeadToCreator } from "../leads/leadsHelpers";
import { InstagramProfile, LongLivedTokenResponse } from "./instagramApiService";

/** Instagram's `profile_picture_url` is a signed, time-limited CDN link —
 * it expires (documented Meta behavior, not a bug), so displaying it
 * directly would mean the photo silently breaks a few hours after every
 * sync. Downloading it once and re-hosting it ourselves gives a stable
 * URL that never expires, independent of Instagram's link lifetime.
 *
 * Uses the Firebase Storage download URL (`firebasestorage.googleapis.com
 * /v0/b/.../o/...?alt=media`), which is gated by `storage.rules`
 * (`instagram-avatars/{userId}: allow read: if true`) — not the raw GCS
 * URL (`storage.googleapis.com/{bucket}/{path}`), which instead depends on
 * the object's own ACL via `file.makePublic()`. That call fails outright
 * on any bucket with Uniform Bucket-Level Access enabled (GCP's default
 * for new buckets), which silently nulled out every creator's mirrored
 * picture — this was the actual cause of Instagram DPs never loading. */
async function mirrorProfilePicture(
  userId: string,
  sourceUrl: string
): Promise<string | null> {
  try {
    const response = await fetch(sourceUrl);
    if (!response.ok) return null;
    const buffer = Buffer.from(await response.arrayBuffer());

    const file = getStorage()
      .bucket()
      .file(`instagram-avatars/${userId}.jpg`);
    await file.save(buffer, { contentType: "image/jpeg" });
    return `https://firebasestorage.googleapis.com/v0/b/${file.bucket.name}/o/${encodeURIComponent(file.name)}?alt=media`;
  } catch (error) {
    logger.error("Failed to mirror Instagram profile picture", error);
    return null;
  }
}

export function accountDoc(userId: string) {
  return getFirestore().collection("instagram_accounts").doc(userId);
}

/** Only Cloud Functions (Admin SDK) can read/write this doc — see the
 * `instagram_accounts/{userId}/private/{doc}` rule in firestore.rules,
 * which denies all client access. This is where the actual access token
 * lives; `instagram_accounts/{userId}` itself only ever holds the
 * profile snapshot + connection status. */
export function tokensDoc(userId: string) {
  return accountDoc(userId).collection("private").doc("tokens");
}

export async function saveTokens(
  userId: string,
  token: LongLivedTokenResponse
): Promise<void> {
  const expiresAt = Timestamp.fromMillis(Date.now() + token.expires_in * 1000);
  await tokensDoc(userId).set({
    accessToken: token.access_token,
    tokenType: token.token_type,
    expiresAt,
    updatedAt: Timestamp.now(),
  });
}

export async function saveProfile(
  userId: string,
  profile: InstagramProfile,
  opts: { connectedAt?: Timestamp } = {}
): Promise<void> {
  const profilePictureUrl = profile.profile_picture_url
    ? await mirrorProfilePicture(userId, profile.profile_picture_url)
    : null;

  await accountDoc(userId).set(
    {
      status: "connected",
      instagramUserId: profile.id,
      username: profile.username ?? null,
      name: profile.name ?? null,
      profilePictureUrl,
      biography: profile.biography ?? null,
      website: profile.website ?? null,
      followersCount: profile.followers_count ?? 0,
      followsCount: profile.follows_count ?? 0,
      mediaCount: profile.media_count ?? 0,
      lastSyncedAt: Timestamp.now(),
      ...(opts.connectedAt ? { connectedAt: opts.connectedAt } : {}),
    },
    { merge: true }
  );

  // Intern outreach attribution: if this is the first time connecting
  // (not just a routine re-sync), check whether this exact Instagram
  // handle matches an outreach lead an intern generated.
  if (opts.connectedAt && profile.username) {
    await matchLeadToCreator(profile.username, userId);
  }
}

export async function markStatus(
  userId: string,
  status: "expired" | "revoked" | "disconnected"
): Promise<void> {
  await accountDoc(userId).set({ status }, { merge: true });
}
