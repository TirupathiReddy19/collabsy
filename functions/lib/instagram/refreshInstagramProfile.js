"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.refreshInstagramProfile = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestoreHelpers_1 = require("./firestoreHelpers");
const instagramApiService_1 = require("./instagramApiService");
const SEVEN_DAYS_MS = 7 * 24 * 60 * 60 * 1000;
/** Manual "Refresh" tap in Connected Accounts — refreshes the long-lived
 * token first if it's within 7 days of expiring, then re-syncs the profile
 * (name, bio, follower/media counts). Proactive refresh here (rather than
 * only in the scheduled job) means a creator who opens the app right
 * before expiry still gets a fresh 60-day window instead of hitting a
 * stale one. */
exports.refreshInstagramProfile = (0, https_1.onCall)(async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
        throw new https_1.HttpsError("unauthenticated", "Sign in required.");
    }
    const tokenSnapshot = await (0, firestoreHelpers_1.tokensDoc)(uid).get();
    const tokenData = tokenSnapshot.data();
    if (!tokenData?.accessToken) {
        throw new https_1.HttpsError("failed-precondition", "Instagram isn't connected.", {
            reason: "token-invalid",
        });
    }
    let accessToken = tokenData.accessToken;
    const expiresAt = tokenData.expiresAt?.toMillis() ?? 0;
    if (expiresAt - Date.now() < SEVEN_DAYS_MS) {
        try {
            const refreshed = await (0, instagramApiService_1.refreshLongLivedToken)({ accessToken });
            await (0, firestoreHelpers_1.saveTokens)(uid, refreshed);
            accessToken = refreshed.access_token;
        }
        catch (error) {
            await (0, firestoreHelpers_1.markStatus)(uid, "expired");
            throw new https_1.HttpsError("failed-precondition", "Couldn't refresh the connection.", { reason: "refresh-failed" });
        }
    }
    try {
        const profile = await (0, instagramApiService_1.fetchProfile)(accessToken);
        await (0, firestoreHelpers_1.saveProfile)(uid, profile);
        return { success: true };
    }
    catch (error) {
        if (error instanceof instagramApiService_1.InstagramApiError) {
            await (0, firestoreHelpers_1.markStatus)(uid, "expired");
            throw new https_1.HttpsError("failed-precondition", error.message, {
                reason: "token-invalid",
            });
        }
        throw new https_1.HttpsError("internal", "Failed to refresh Instagram data.");
    }
});
