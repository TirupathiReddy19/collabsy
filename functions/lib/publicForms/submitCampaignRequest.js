"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.submitCampaignRequest = void 0;
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const emailConfig_1 = require("../shared/emailConfig");
const emailTemplate_1 = require("../shared/emailTemplate");
const sendEmail_1 = require("../shared/sendEmail");
const rateLimit_1 = require("./rateLimit");
const validation_1 = require("./validation");
const BUDGET_LABELS = {
    under_50k: "Under ₹50,000",
    "50k_2l": "₹50,000 – ₹2,00,000",
    "2l_10l": "₹2,00,000 – ₹10,00,000",
    "10l_plus": "₹10,00,000+",
    not_sure: "Not sure yet",
};
const NOTIFY_ADDRESS = "admin@collabsy.online";
/**
 * The Brands page's "run it for us" form. Replaces the website writing to
 * `campaignRequests` directly (an anonymous Firestore create), so the input
 * is validated here and one visitor, and the form as a whole, can only send
 * so many per hour. The doc written is exactly what the old rule allowed, so
 * the admin portal reads it unchanged.
 */
exports.submitCampaignRequest = (0, https_1.onCall)({ secrets: [emailConfig_1.smtpHost, emailConfig_1.smtpPort, emailConfig_1.smtpUser, emailConfig_1.smtpPassword] }, async (request) => {
    const input = (0, validation_1.parseCampaignRequest)(request.data);
    await (0, rateLimit_1.enforceRateLimit)(request, {
        bucket: "campaignRequest",
        perCallerLimit: 5,
        globalLimit: 100,
    });
    await (0, firestore_1.getFirestore)().collection("campaignRequests").add({
        companyName: input.companyName,
        contactName: input.contactName,
        workEmail: input.workEmail,
        ...(input.phone ? { phone: input.phone } : {}),
        budgetRange: input.budgetRange,
        campaignBrief: input.campaignBrief,
        status: "new",
        createdAt: firestore_1.Timestamp.now(),
    });
    const budgetLabel = BUDGET_LABELS[input.budgetRange] ?? input.budgetRange;
    // Best-effort, non-fatal (see sendEmail) — never block the response on
    // these, and never let a bad send roll back the write above. Run in
    // parallel; they're independent of each other.
    await Promise.all([
        (0, sendEmail_1.sendEmail)({
            to: NOTIFY_ADDRESS,
            subject: `New campaign request from ${input.companyName}`,
            html: (0, emailTemplate_1.wrapEmailHtml)(`
          <p style="font-size: 16px; margin: 0 0 16px;">New campaign request submitted on collabsy.online/brands.</p>
          <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
            <tr><td style="padding: 6px 0; color: #6b7280;">Company</td><td style="padding: 6px 0;">${(0, emailTemplate_1.escapeHtml)(input.companyName)}</td></tr>
            <tr><td style="padding: 6px 0; color: #6b7280;">Contact</td><td style="padding: 6px 0;">${(0, emailTemplate_1.escapeHtml)(input.contactName)}</td></tr>
            <tr><td style="padding: 6px 0; color: #6b7280;">Email</td><td style="padding: 6px 0;">${(0, emailTemplate_1.escapeHtml)(input.workEmail)}</td></tr>
            ${input.phone ? `<tr><td style="padding: 6px 0; color: #6b7280;">Phone</td><td style="padding: 6px 0;">${(0, emailTemplate_1.escapeHtml)(input.phone)}</td></tr>` : ""}
            <tr><td style="padding: 6px 0; color: #6b7280;">Budget</td><td style="padding: 6px 0;">${(0, emailTemplate_1.escapeHtml)(budgetLabel)}</td></tr>
          </table>
          <p style="margin: 16px 0 0; color: #6b7280;">Brief</p>
          <p style="margin: 4px 0 0; white-space: pre-wrap;">${(0, emailTemplate_1.escapeHtml)(input.campaignBrief)}</p>
        `),
        }),
        (0, sendEmail_1.sendEmail)({
            to: input.workEmail,
            subject: "We got your campaign request — Collabsy",
            html: (0, emailTemplate_1.wrapEmailHtml)(`
          <p style="font-size: 16px; margin: 0 0 16px;">Hi ${(0, emailTemplate_1.escapeHtml)(input.contactName)},</p>
          <p style="margin: 0 0 16px;">
            Thanks for telling us about your campaign — we've received your request and
            someone from our team will reach out to ${(0, emailTemplate_1.escapeHtml)(input.workEmail)} shortly.
          </p>
          <p style="margin: 0;">— The Collabsy team</p>
        `),
        }),
    ]);
    return { success: true };
});
