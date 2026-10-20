import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";

import { smtpHost, smtpPassword, smtpPort, smtpUser } from "../shared/emailConfig";
import { escapeHtml, wrapEmailHtml } from "../shared/emailTemplate";
import { sendEmail } from "../shared/sendEmail";
import { enforceRateLimit } from "./rateLimit";
import { parseCampaignRequest } from "./validation";

const BUDGET_LABELS: Record<string, string> = {
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
export const submitCampaignRequest = onCall(
  { secrets: [smtpHost, smtpPort, smtpUser, smtpPassword] },
  async (request) => {
    const input = parseCampaignRequest(request.data);
    await enforceRateLimit(request, {
      bucket: "campaignRequest",
      perCallerLimit: 5,
      globalLimit: 100,
    });

    await getFirestore().collection("campaignRequests").add({
      companyName: input.companyName,
      contactName: input.contactName,
      workEmail: input.workEmail,
      ...(input.phone ? { phone: input.phone } : {}),
      budgetRange: input.budgetRange,
      campaignBrief: input.campaignBrief,
      status: "new",
      createdAt: Timestamp.now(),
    });

    const budgetLabel = BUDGET_LABELS[input.budgetRange] ?? input.budgetRange;

    // Best-effort, non-fatal (see sendEmail) — never block the response on
    // these, and never let a bad send roll back the write above. Run in
    // parallel; they're independent of each other.
    await Promise.all([
      sendEmail({
        to: NOTIFY_ADDRESS,
        subject: `New campaign request from ${input.companyName}`,
        html: wrapEmailHtml(`
          <p style="font-size: 16px; margin: 0 0 16px;">New campaign request submitted on collabsy.online/brands.</p>
          <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
            <tr><td style="padding: 6px 0; color: #6b7280;">Company</td><td style="padding: 6px 0;">${escapeHtml(input.companyName)}</td></tr>
            <tr><td style="padding: 6px 0; color: #6b7280;">Contact</td><td style="padding: 6px 0;">${escapeHtml(input.contactName)}</td></tr>
            <tr><td style="padding: 6px 0; color: #6b7280;">Email</td><td style="padding: 6px 0;">${escapeHtml(input.workEmail)}</td></tr>
            ${input.phone ? `<tr><td style="padding: 6px 0; color: #6b7280;">Phone</td><td style="padding: 6px 0;">${escapeHtml(input.phone)}</td></tr>` : ""}
            <tr><td style="padding: 6px 0; color: #6b7280;">Budget</td><td style="padding: 6px 0;">${escapeHtml(budgetLabel)}</td></tr>
          </table>
          <p style="margin: 16px 0 0; color: #6b7280;">Brief</p>
          <p style="margin: 4px 0 0; white-space: pre-wrap;">${escapeHtml(input.campaignBrief)}</p>
        `),
      }),
      sendEmail({
        to: input.workEmail,
        subject: "We got your campaign request — Collabsy",
        html: wrapEmailHtml(`
          <p style="font-size: 16px; margin: 0 0 16px;">Hi ${escapeHtml(input.contactName)},</p>
          <p style="margin: 0 0 16px;">
            Thanks for telling us about your campaign — we've received your request and
            someone from our team will reach out to ${escapeHtml(input.workEmail)} shortly.
          </p>
          <p style="margin: 0;">— The Collabsy team</p>
        `),
      }),
    ]);

    return { success: true };
  }
);
