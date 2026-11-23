"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.computeEngagementRate = computeEngagementRate;
exports.refreshEngagementRate = refreshEngagementRate;
const firestore_1 = require("firebase-admin/firestore");
const firebase_functions_1 = require("firebase-functions");
const firestoreHelpers_1 = require("./firestoreHelpers");
const instagramApiService_1 = require("./instagramApiService");
/** Pure function, no network/Firestore — easy to unit-test and to reason
 * about independently of the API call that feeds it. Returns null when a
 * rate genuinely can't be computed (no posts yet, or zero followers would
 * make the result meaningless/divide-by-zero), never a misleading 0.
 *
 * Averages over whatever `fetchRecentMedia` returned (up to 50 posts, not
 * the account's full history — see that function's own comment for why). */
function computeEngagementRate(media, followersCount) {
    if (followersCount <= 0)
        return null;
    // Only posts that actually returned both counts — a post with comments
    // disabled still reports comments_count: 0 (a real number), so this only
    // excludes posts the API genuinely didn't return engagement fields for,
    // not posts with genuinely zero engagement.
    const scored = media.filter((m) => typeof m.like_count === "number" && typeof m.comments_count === "number");
    if (scored.length === 0)
        return null;
    const totalEngagement = scored.reduce((sum, m) => sum + (m.like_count ?? 0) + (m.comments_count ?? 0), 0);
    const averagePerPost = totalEngagement / scored.length;
    const engagementRate = (averagePerPost / followersCount) * 100;
    return {
        engagementRate: Math.round(engagementRate * 100) / 100,
        engagementSampleSize: scored.length,
    };
}
/** Best-effort, non-fatal — same shape as `mirrorProfilePicture` elsewhere
 * in this codebase: a failure here (rate limit, a media type the API
 * didn't expect) must never fail the profile sync it's attached to, since
 * the engagement rate is a bonus signal, not the thing the sync exists for.
 * Called after `saveProfile` at every one of its three call sites
 * (initial connect, manual refresh, the 2-hourly background sync). */
async function refreshEngagementRate(userId, accessToken, followersCount) {
    try {
        const media = await (0, instagramApiService_1.fetchRecentMedia)(accessToken);
        const result = computeEngagementRate(media, followersCount);
        await (0, firestoreHelpers_1.accountDoc)(userId).set({
            engagementRate: result?.engagementRate ?? null,
            engagementSampleSize: result?.engagementSampleSize ?? 0,
            engagementComputedAt: firestore_1.Timestamp.now(),
        }, { merge: true });
    }
    catch (error) {
        firebase_functions_1.logger.error("Skipped engagement-rate refresh", { userId, error });
    }
}
