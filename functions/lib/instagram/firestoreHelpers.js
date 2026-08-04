"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.accountDoc = accountDoc;
exports.tokensDoc = tokensDoc;
exports.saveTokens = saveTokens;
exports.saveProfile = saveProfile;
exports.saveMedia = saveMedia;
exports.markStatus = markStatus;
const firestore_1 = require("firebase-admin/firestore");
const storage_1 = require("firebase-admin/storage");
const firebase_functions_1 = require("firebase-functions");
const leadsHelpers_1 = require("../leads/leadsHelpers");
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
async function mirrorProfilePicture(userId, sourceUrl) {
    try {
        const response = await fetch(sourceUrl);
        if (!response.ok)
            return null;
        const buffer = Buffer.from(await response.arrayBuffer());
        const file = (0, storage_1.getStorage)()
            .bucket()
            .file(`instagram-avatars/${userId}.jpg`);
        await file.save(buffer, { contentType: "image/jpeg" });
        return `https://firebasestorage.googleapis.com/v0/b/${file.bucket.name}/o/${encodeURIComponent(file.name)}?alt=media`;
    }
    catch (error) {
        firebase_functions_1.logger.error("Failed to mirror Instagram profile picture", error);
        return null;
    }
}
function accountDoc(userId) {
    return (0, firestore_1.getFirestore)().collection("instagram_accounts").doc(userId);
}
/** Only Cloud Functions (Admin SDK) can read/write this doc — see the
 * `instagram_accounts/{userId}/private/{doc}` rule in firestore.rules,
 * which denies all client access. This is where the actual access token
 * lives; `instagram_accounts/{userId}` itself only ever holds the
 * profile snapshot + connection status. */
function tokensDoc(userId) {
    return accountDoc(userId).collection("private").doc("tokens");
}
async function saveTokens(userId, token) {
    const expiresAt = firestore_1.Timestamp.fromMillis(Date.now() + token.expires_in * 1000);
    await tokensDoc(userId).set({
        accessToken: token.access_token,
        tokenType: token.token_type,
        expiresAt,
        updatedAt: firestore_1.Timestamp.now(),
    });
}
async function saveProfile(userId, profile, opts = {}) {
    const profilePictureUrl = profile.profile_picture_url
        ? await mirrorProfilePicture(userId, profile.profile_picture_url)
        : null;
    await accountDoc(userId).set({
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
        lastSyncedAt: firestore_1.Timestamp.now(),
        ...(opts.connectedAt ? { connectedAt: opts.connectedAt } : {}),
    }, { merge: true });
    // Intern outreach attribution: if this is the first time connecting
    // (not just a routine re-sync), check whether this exact Instagram
    // handle matches an outreach lead an intern generated.
    if (opts.connectedAt && profile.username) {
        await (0, leadsHelpers_1.matchLeadToCreator)(profile.username, userId);
    }
}
async function saveMedia(userId, items) {
    const firestore = (0, firestore_1.getFirestore)();
    const batchSize = 400; // Firestore batch write limit is 500
    for (let i = 0; i < items.length; i += batchSize) {
        const batch = firestore.batch();
        for (const item of items.slice(i, i + batchSize)) {
            const ref = firestore.collection("instagram_media").doc(item.id);
            batch.set(ref, {
                userId,
                mediaUrl: item.media_url ?? null,
                mediaType: item.media_type ?? null,
                thumbnailUrl: item.thumbnail_url ?? null,
                permalink: item.permalink ?? null,
                caption: item.caption ?? null,
                timestamp: item.timestamp
                    ? firestore_1.Timestamp.fromDate(new Date(item.timestamp))
                    : null,
            }, { merge: true });
        }
        await batch.commit();
    }
}
async function markStatus(userId, status) {
    await accountDoc(userId).set({ status }, { merge: true });
}
