import { defineSecret, defineString } from "firebase-functions/params";

/** Set via `firebase functions:secrets:set INSTAGRAM_APP_SECRET` — never
 * committed, never sent to the client. */
export const instagramAppSecret = defineSecret("INSTAGRAM_APP_SECRET");

/** Not sensitive (it's the same value the Flutter app sends as
 * `client_id` in the authorize URL) but centralized here so the token
 * exchange always uses the exact same value the redirect was issued for. */
export const instagramAppId = defineString("INSTAGRAM_APP_ID");

/** Must exactly match (including trailing slash, per Meta's own dashboard
 * warning) the redirect URI registered on the Instagram product and the
 * one Flutter's `InstagramConfig.redirectUri` sends. */
export const instagramRedirectUri = defineString("INSTAGRAM_REDIRECT_URI");
