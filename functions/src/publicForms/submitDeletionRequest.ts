import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";

import { smtpHost, smtpPassword, smtpPort, smtpUser } from "../shared/emailConfig";
import { escapeHtml, wrapEmailHtml } from "../shared/emailTemplate";
import { sendEmail } from "../shared/sendEmail";
import { enforceRateLimit } from "./rateLimit";
import { parseDeletionRequest } from "./validation";

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
export const submitDeletionRequest = onCall(
  { secrets: [smtpHost, smtpPort, smtpUser, smtpPassword] },
  async (request) => {
    const input = parseDeletionRequest(request.data);
    await enforceRateLimit(request, {
      bucket: "deletionRequest",
      perCallerLimit: 3,
      globalLimit: 60,
    });

    await getFirestore().collection("accountDeletionRequests").add({
      identifier: input.identifier,
      ...(input.reason ? { reason: input.reason } : {}),
      status: "pending",
      createdAt: Timestamp.now(),
    });

    const emailSends = [
      sendEmail({
        to: NOTIFY_ADDRESS,
        subject: "New account deletion request",
        html: wrapEmailHtml(`
          <p style="font-size: 16px; margin: 0 0 16px;">New account deletion request submitted on collabsy.online.</p>
          <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
            <tr><td style="padding: 6px 0; color: #6b7280;">Identifier</td><td style="padding: 6px 0;">${escapeHtml(input.identifier)}</td></tr>
          </table>
          ${
            input.reason
              ? `<p style="margin: 16px 0 0; color: #6b7280;">Reason</p>
                 <p style="margin: 4px 0 0; white-space: pre-wrap;">${escapeHtml(input.reason)}</p>`
              : ""
          }
        `),
      }),
    ];

    if (EMAIL_PATTERN.test(input.identifier)) {
      emailSends.push(
        sendEmail({
          to: input.identifier,
          subject: "We got your account deletion request — Collabsy",
          html: wrapEmailHtml(`
            <p style="font-size: 16px; margin: 0 0 16px;">Hi,</p>
            <p style="margin: 0 0 16px;">
              We've received your request to delete your Collabsy account. Our team will
              verify it and process the deletion — you'll be removed from the platform
              once that's done.
            </p>
            <p style="margin: 0;">— The Collabsy team</p>
          `),
        })
      );
    }

    // Best-effort, non-fatal (see sendEmail) — never block the response on
    // these, and never let a bad send roll back the write above.
    await Promise.all(emailSends);

    return { success: true };
  }
);
