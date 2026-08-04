"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.exchangeInstagramCode = void 0;
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const config_1 = require("./config");
const firestoreHelpers_1 = require("./firestoreHelpers");
const instagramApiService_1 = require("./instagramApiService");
/** Callable from Flutter with `{ code }` — the authorization code from the
 * OAuth redirect. Does the full short-lived -> long-lived token exchange
 * and the initial profile/media sync entirely server-side; the App Secret
 * this requires (via the `instagramAppSecret` param) never leaves this
 * function. */
exports.exchangeInstagramCode = (0, https_1.onCall)({ secrets: [config_1.instagramAppSecret] }, async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
        throw new https_1.HttpsError("unauthenticated", "Sign in required.");
    }
    const code = request.data?.code;
    if (typeof code !== "string" || code.length === 0) {
        throw new https_1.HttpsError("invalid-argument", "Missing authorization code.");
    }
    try {
        const shortLived = await (0, instagramApiService_1.exchangeCodeForShortLivedToken)({
            appId: config_1.instagramAppId.value(),
            appSecret: config_1.instagramAppSecret.value(),
            code,
            redirectUri: config_1.instagramRedirectUri.value(),
        });
        const longLived = await (0, instagramApiService_1.exchangeForLongLivedToken)({
            appSecret: config_1.instagramAppSecret.value(),
            shortLivedToken: shortLived.access_token,
        });
        await (0, firestoreHelpers_1.saveTokens)(uid, longLived);
        const profile = await (0, instagramApiService_1.fetchProfile)(longLived.access_token);
        await (0, firestoreHelpers_1.saveProfile)(uid, profile, { connectedAt: firestore_1.Timestamp.now() });
        const media = await (0, instagramApiService_1.fetchMedia)(longLived.access_token);
        await (0, firestoreHelpers_1.saveMedia)(uid, media);
        return { success: true };
    }
    catch (error) {
        if (error instanceof instagramApiService_1.InstagramApiError) {
            throw new https_1.HttpsError("failed-precondition", error.message, {
                reason: "token-invalid",
            });
        }
        throw new https_1.HttpsError("internal", "Failed to connect Instagram.");
    }
});
