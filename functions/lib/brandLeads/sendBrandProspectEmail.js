"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendBrandProspectEmail = void 0;
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const adminAuth_1 = require("../shared/adminAuth");
const emailConfig_1 = require("../shared/emailConfig");
const emailTemplate_1 = require("../shared/emailTemplate");
const sendEmail_1 = require("../shared/sendEmail");
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
exports.sendBrandProspectEmail = (0, https_1.onCall)({ secrets: [emailConfig_1.smtpHost, emailConfig_1.smtpPort, emailConfig_1.smtpUser, emailConfig_1.smtpPassword] }, async (request) => {
    await (0, adminAuth_1.requireAdminOrPermission)(request, PERMISSION);
    const { prospectId, to, subject, body } = (request.data ?? {});
    if (!prospectId || !to || !subject?.trim() || !body?.trim()) {
        throw new https_1.HttpsError("invalid-argument", "Missing prospectId, to, subject, or body.");
    }
    const db = (0, firestore_1.getFirestore)();
    const ref = db.collection("brandProspects").doc(prospectId);
    const snap = await ref.get();
    if (!snap.exists) {
        throw new https_1.HttpsError("not-found", "That prospect no longer exists.");
    }
    const data = snap.data();
    const isSuperAdmin = request.auth.token.email === "admin@collabsy.online";
    if (!isSuperAdmin && data.assignedTo !== request.auth.uid) {
        throw new https_1.HttpsError("permission-denied", "This prospect isn't assigned to you.");
    }
    const knownEmails = Array.isArray(data.emails) ? data.emails : [];
    if (!knownEmails.includes(to)) {
        throw new https_1.HttpsError("invalid-argument", "That address isn't one of this prospect's emails on file.");
    }
    const sent = await (0, sendEmail_1.sendEmail)({
        to,
        subject: subject.trim(),
        html: body
            .trim()
            .split(/\n{2,}/)
            .map((para) => `<p style="margin: 0 0 16px;">${(0, emailTemplate_1.escapeHtml)(para).replace(/\n/g, "<br>")}</p>`)
            .join(""),
        replyTo: request.auth.token.email,
    });
    if (!sent) {
        throw new https_1.HttpsError("internal", "The email failed to send. Please try again.");
    }
    await ref.update({
        emailSentAt: firestore_1.FieldValue.serverTimestamp(),
        emailSentCount: firestore_1.FieldValue.increment(1),
        ...(data.contacted
            ? {}
            : { contacted: true, contactedAt: firestore_1.FieldValue.serverTimestamp() }),
    });
    return { ok: true };
});
