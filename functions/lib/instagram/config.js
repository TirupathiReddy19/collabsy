"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.instagramRedirectUri = exports.instagramAppId = exports.instagramAppSecret = void 0;
const params_1 = require("firebase-functions/params");
/** Set via `firebase functions:secrets:set INSTAGRAM_APP_SECRET` — never
 * committed, never sent to the client. */
exports.instagramAppSecret = (0, params_1.defineSecret)("INSTAGRAM_APP_SECRET");
/** Not sensitive (it's the same value the Flutter app sends as
 * `client_id` in the authorize URL) but centralized here so the token
 * exchange always uses the exact same value the redirect was issued for. */
exports.instagramAppId = (0, params_1.defineString)("INSTAGRAM_APP_ID");
/** Must exactly match (including trailing slash, per Meta's own dashboard
 * warning) the redirect URI registered on the Instagram product and the
 * one Flutter's `InstagramConfig.redirectUri` sends. */
exports.instagramRedirectUri = (0, params_1.defineString)("INSTAGRAM_REDIRECT_URI");
