"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.submitDeletionRequest = void 0;
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const emailConfig_1 = require("../shared/emailConfig");
const emailTemplate_1 = require("../shared/emailTemplate");
const sendEmail_1 = require("../shared/sendEmail");
const rateLimit_1 = require("./rateLimit");
const validation_1 = require("./validation");
const NOTIFY_ADDRESS = "support@collabsy.online";
// The form itself accepts "email or phone" (no format requirement on the
// identifier — see website_delete_account_screen.dart's own label), so a
// confirmation can only go out when it actually looks like an email;
// there's no SMS-sending capability to fall back to for a phone number.
const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
/**
 * The website's "Request account deletion" form, for people who can't open
 * the app. Replaces an anonymous Firestore create with a validated,
 * rate-limited call. The doc is identical to the old one; staff still
 * verify each request before anything is deleted.
 */
exports.submitDeletionRequest = (0, https_1.onCall)({ secrets: [emailConfig_1.smtpHost, emailConfig_1.smtpPort, emailConfig_1.smtpUser, emailConfig_1.smtpPassword] }, async (request) => {
    const input = (0, validation_1.parseDeletionRequest)(request.data);
    await (0, rateLimit_1.enforceRateLimit)(request, {
        bucket: "deletionRequest",
        perCallerLimit: 3,
        globalLimit: 60,
    });
    await (0, firestore_1.getFirestore)().collection("accountDeletionRequests").add({
        identifier: input.identifier,
        ...(input.reason ? { reason: input.reason } : {}),
        status: "pending",
        createdAt: firestore_1.Timestamp.now(),
    });
    const emailSends = [
        (0, sendEmail_1.sendEmail)({
            to: NOTIFY_ADDRESS,
            subject: "New account deletion request",
            html: (0, emailTemplate_1.wrapEmailHtml)(`
          <p style="font-size: 16px; margin: 0 0 16px;">New account deletion request submitted on collabsy.online.</p>
          <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
            <tr><td style="padding: 6px 0; color: #6b7280;">Identifier</td><td style="padding: 6px 0;">${(0, emailTemplate_1.escapeHtml)(input.identifier)}</td></tr>
          </table>
          ${input.reason
                ? `<p style="margin: 16px 0 0; color: #6b7280;">Reason</p>
                 <p style="margin: 4px 0 0; white-space: pre-wrap;">${(0, emailTemplate_1.escapeHtml)(input.reason)}</p>`
                : ""}
        `),
        }),
    ];
    if (EMAIL_PATTERN.test(input.identifier)) {
        emailSends.push((0, sendEmail_1.sendEmail)({
            to: input.identifier,
            subject: "We got your account deletion request — Collabsy",
            html: (0, emailTemplate_1.wrapEmailHtml)(`
            <p style="font-size: 16px; margin: 0 0 16px;">Hi,</p>
            <p style="margin: 0 0 16px;">
              We've received your request to delete your Collabsy account. Our team will
              verify it and process the deletion — you'll be removed from the platform
              once that's done.
            </p>
            <p style="margin: 0;">— The Collabsy team</p>
          `),
        }));
    }
    // Best-effort, non-fatal (see sendEmail) — never block the response on
    // these, and never let a bad send roll back the write above.
    await Promise.all(emailSends);
    return { success: true };
});
