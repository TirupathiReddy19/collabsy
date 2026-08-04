"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.InstagramApiError = void 0;
exports.exchangeCodeForShortLivedToken = exchangeCodeForShortLivedToken;
exports.exchangeForLongLivedToken = exchangeForLongLivedToken;
exports.refreshLongLivedToken = refreshLongLivedToken;
exports.fetchProfile = fetchProfile;
exports.fetchMedia = fetchMedia;
const firebase_functions_1 = require("firebase-functions");
// Instagram Business Login (the current "Instagram API with Instagram
// Login" product) — deliberately NOT the deprecated Instagram Basic
// Display API. Endpoints/params verified against Meta's live docs as of
// this writing:
//   https://developers.facebook.com/documentation/instagram-platform/instagram-api-with-instagram-login/business-login
const SHORT_LIVED_TOKEN_URL = "https://api.instagram.com/oauth/access_token";
const GRAPH_HOST = "https://graph.instagram.com";
const API_VERSION = "v25.0";
class InstagramApiError extends Error {
    constructor(message, code, status) {
        super(message);
        this.code = code;
        this.status = status;
    }
}
exports.InstagramApiError = InstagramApiError;
async function parseJsonOrThrow(response, context) {
    const body = await response.json().catch(() => null);
    if (!response.ok) {
        const message = body?.error_message || body?.error?.message || `${context} failed`;
        const errorType = body?.error_type || body?.error?.type;
        firebase_functions_1.logger.error(`Instagram API error (${context})`, {
            status: response.status,
            body,
        });
        // Meta reports both an expired token and a revoked one as the same
        // generic OAuthException — there's no documented, reliable subcode to
        // tell them apart, so both are surfaced the same way here.
        if (response.status === 400 || errorType === "OAuthException") {
            throw new InstagramApiError(message, "token-invalid", response.status);
        }
        throw new InstagramApiError(message, "request-failed", response.status);
    }
    return body;
}
async function exchangeCodeForShortLivedToken(params) {
    const body = new URLSearchParams({
        client_id: params.appId,
        client_secret: params.appSecret,
        grant_type: "authorization_code",
        redirect_uri: params.redirectUri,
        code: params.code,
    });
    const response = await fetch(SHORT_LIVED_TOKEN_URL, {
        method: "POST",
        body,
    });
    return parseJsonOrThrow(response, "short-lived token exchange");
}
/** Exchanges a short-lived token for a 60-day long-lived one. This is the
 * *current, non-deprecated* mechanism for this API — `ig_exchange_token`
 * is just the grant_type name Meta's docs specify, not a legacy leftover. */
async function exchangeForLongLivedToken(params) {
    const url = new URL(`${GRAPH_HOST}/access_token`);
    url.searchParams.set("grant_type", "ig_exchange_token");
    url.searchParams.set("client_secret", params.appSecret);
    url.searchParams.set("access_token", params.shortLivedToken);
    const response = await fetch(url);
    return parseJsonOrThrow(response, "long-lived token exchange");
}
/** Refreshes a long-lived token for another 60 days. Only works once the
 * token is at least 24h old and still valid — a token that's already
 * expired or been revoked can't be refreshed and needs a full reconnect. */
async function refreshLongLivedToken(params) {
    const url = new URL(`${GRAPH_HOST}/refresh_access_token`);
    url.searchParams.set("grant_type", "ig_refresh_token");
    url.searchParams.set("access_token", params.accessToken);
    const response = await fetch(url);
    return parseJsonOrThrow(response, "token refresh");
}
async function fetchProfile(accessToken) {
    const fields = [
        "id",
        "username",
        "name",
        "profile_picture_url",
        "biography",
        "website",
        "followers_count",
        "follows_count",
        "media_count",
    ].join(",");
    const url = new URL(`${GRAPH_HOST}/${API_VERSION}/me`);
    url.searchParams.set("fields", fields);
    url.searchParams.set("access_token", accessToken);
    const response = await fetch(url);
    return parseJsonOrThrow(response, "fetch profile");
}
/** Fetches up to [limit] most recent media items, following pagination. */
async function fetchMedia(accessToken, limit = 50) {
    const fields = [
        "id",
        "media_type",
        "media_url",
        "thumbnail_url",
        "permalink",
        "caption",
        "timestamp",
    ].join(",");
    const url = new URL(`${GRAPH_HOST}/${API_VERSION}/me/media`);
    url.searchParams.set("fields", fields);
    url.searchParams.set("limit", String(Math.min(limit, 100)));
    url.searchParams.set("access_token", accessToken);
    const items = [];
    let nextUrl = url;
    while (nextUrl && items.length < limit) {
        const response = await fetch(nextUrl);
        const body = await parseJsonOrThrow(response, "fetch media");
        items.push(...(body.data ?? []));
        nextUrl = body.paging?.next ?? null;
    }
    return items.slice(0, limit);
}
