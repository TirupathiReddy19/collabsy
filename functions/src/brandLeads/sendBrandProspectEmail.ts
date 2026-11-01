import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { requireAdminOrPermission } from "../shared/adminAuth";
import { smtpHost, smtpPassword, smtpPort, smtpUser } from "../shared/emailConfig";
import { escapeHtml } from "../shared/emailTemplate";
import { sendEmail } from "../shared/sendEmail";

const PERMISSION = "/brand-outreach-leads";

/**
 * One-click outreach email for the brand-intern tool's "My Prospects" tab —
 * sends through the same Modoboa mailbox as every other transactional email
 * this codebase sends (see `sendEmail`), reply-to'd to the calling intern so
 * a response lands with them directly rather than the shared mailbox.
 *
 * Deliberately a Cloud Function rather than a client-side `mailto:` link:
 * the brand-outreach permission already gates *who* can see a prospect's
 * email at all, and this keeps that same boundary for *sending* to it,
 * plus it can record `emailSentAt`/`emailSentCount` on the prospect
 * afterward — a client write couldn't do that without widening the
 * self-report rule (`firestore.rules`' `brandProspects` match) far beyond
 * its current one-way `contacted` flip.
 */
export const sendBrandProspectEmail = onCall(
  { secrets: [smtpHost, smtpPort, smtpUser, smtpPassword] },
  async (request) => {
    await requireAdminOrPermission(request, PERMISSION);

    const { prospectId, to, subject, body } = (request.data ?? {}) as {
      prospectId?: string;
      to?: string;
      subject?: string;
      body?: string;
    };
    if (!prospectId || !to || !subject?.trim() || !body?.trim()) {
      throw new HttpsError("invalid-argument", "Missing prospectId, to, subject, or body.");
    }

    const db = getFirestore();
    const ref = db.collection("brandProspects").doc(prospectId);
    const snap = await ref.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "That prospect no longer exists.");
    }
    const data = snap.data()!;

    const isSuperAdmin = request.auth!.token.email === "admin@collabsy.online";
    if (!isSuperAdmin && data.assignedTo !== request.auth!.uid) {
      throw new HttpsError("permission-denied", "This prospect isn't assigned to you.");
    }

    const knownEmails: string[] = Array.isArray(data.emails) ? data.emails : [];
    if (!knownEmails.includes(to)) {
      throw new HttpsError(
        "invalid-argument",
        "That address isn't one of this prospect's emails on file."
      );
    }

    const sent = await sendEmail({
      to,
      subject: subject.trim(),
      html: body
        .trim()
        .split(/\n{2,}/)
        .map((para) => `<p style="margin: 0 0 16px;">${escapeHtml(para).replace(/\n/g, "<br>")}</p>`)
        .join(""),
      replyTo: request.auth!.token.email,
    });
    if (!sent) {
      throw new HttpsError("internal", "The email failed to send. Please try again.");
    }

    await ref.update({
      emailSentAt: FieldValue.serverTimestamp(),
      emailSentCount: FieldValue.increment(1),
      ...(data.contacted
        ? {}
        : { contacted: true, contactedAt: FieldValue.serverTimestamp() }),
    });

    return { ok: true };
  }
);
