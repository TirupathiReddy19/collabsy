"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.instagramOAuthRedirect = void 0;
const https_1 = require("firebase-functions/v2/https");
/** The registered OAuth redirect URI for Instagram Business Login. In
 * normal operation the Flutter app's WebView intercepts and cancels this
 * navigation before it ever reaches this function (see
 * InstagramOAuthWebViewScreen) — this exists as a real, reachable HTTPS
 * endpoint because Meta's App Dashboard requires the redirect URI to be
 * one, and as a fallback if that interception ever races. */
exports.instagramOAuthRedirect = (0, https_1.onRequest)((req, res) => {
    res.status(200).send(`<!DOCTYPE html>
<html>
  <head><title>Collabsy</title></head>
  <body style="font-family: sans-serif; text-align: center; padding-top: 3rem;">
    <p>You can close this window and return to the Collabsy app.</p>
  </body>
</html>`);
});
