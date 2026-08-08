"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkEmailRegistered = void 0;
const auth_1 = require("firebase-admin/auth");
const https_1 = require("firebase-functions/v2/https");
/**
 * Tells the login screen whether an email has an account at all, so an
 * unregistered email can be redirected straight into signup instead of a
 * generic "incorrect email or password" message — deliberately callable
 * while signed out, since that's the whole point.
 *
 * Needs the Admin SDK because the client-side sign-in error is intentionally
 * ambiguous (`invalid-credential` covers both "wrong password" and "no such
 * user", specifically to stop email-existence probing). This function is a
 * deliberate, product-requested exception to that protection — same
 * "redirect to signup" UX phone login already gets, where there was never
 * anything to protect (a phone OTP already proves live ownership).
 */
exports.checkEmailRegistered = (0, https_1.onCall)(async (request) => {
    const email = request.data?.email?.trim();
    if (!email) {
        throw new https_1.HttpsError("invalid-argument", "email is required.");
    }
    try {
        await (0, auth_1.getAuth)().getUserByEmail(email);
        return { registered: true };
    }
    catch (error) {
        if (error.code === "auth/user-not-found") {
            return { registered: false };
        }
        throw error;
    }
});
