"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.remindPendingVerifications = void 0;
const firestore_1 = require("firebase-admin/firestore");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const params_1 = require("firebase-functions/params");
const firebase_functions_1 = require("firebase-functions");
const sendEmail_1 = require("../shared/sendEmail");
const emailTemplate_1 = require("../shared/emailTemplate");
/** Base URL of the admin portal (Flutter web, hosting target "admin").
 * Defaults to the Firebase-provided domain; override with:
 *   firebase functions:config:set — no, this project uses params, so:
 *   set via the Firebase console's "Parameters" panel for this function,
 *   or `firebase deploy --only functions --set-params ADMIN_PORTAL_URL=https://admin.collabsy.online`
 * if a custom domain is ever mapped to the "collabsy-admin" hosting site. */
const adminPortalUrl = (0, params_1.defineString)("ADMIN_PORTAL_URL", {
    default: "https://collabsy-admin.web.app",
});
const REMINDER_THRESHOLD_MINUTES = 15;
const REMINDER_RECIPIENT = "hello@collabsy.online";
/** One pass of the pending-review queue: finds every creator/brand profile
 * sitting at `verificationStatus: pending` that's either been waiting at
 * least [REMINDER_THRESHOLD_MINUTES] (per its `verificationRequestedAt`
 * stamp) or has no stamp at all (a pre-existing backlog profile from before
 * this feature shipped — treated as overdue immediately rather than ignored
 * forever), and hasn't already been reminded about (`reminderSentAt` unset).
 *
 * This is a single, one-time reminder per pending period — not a repeating
 * nag every 5 minutes until someone acts. If a profile is later rejected and
 * resubmitted (verificationStatus goes back to pending),
 * `stampVerificationRequestedAt` starts the clock over and this can remind
 * again for that new wait.
 *
 * Deliberately a single equality `where` (no range filter) with the time/
 * reminder-sent logic done in memory: Firestore can't combine a range filter
 * on `verificationRequestedAt` with a "field doesn't exist" filter in one
 * query, and the pending queue is small enough (tens, not thousands, of
 * profiles) that fetching every pending doc and filtering client-side is
 * simpler than a second denormalized field just to make the query possible.
 */
async function findReminderCandidates(threshold) {
    const firestore = (0, firestore_1.getFirestore)();
    const candidates = [];
    const creatorSnap = await firestore
        .collection("creatorProfiles")
        .where("verificationStatus", "==", "pending")
        .get();
    firebase_functions_1.logger.info(`findReminderCandidates: ${creatorSnap.size} creatorProfiles pending`);
    for (const doc of creatorSnap.docs) {
        const data = doc.data();
        if (data.reminderSentAt)
            continue;
        const requestedAt = data.verificationRequestedAt ?? null;
        if (requestedAt && requestedAt.toMillis() > threshold.toMillis())
            continue;
        candidates.push({
            id: doc.id,
            kind: "creator",
            label: data.displayName || doc.id,
            waitingSince: requestedAt,
        });
    }
    const brandSnap = await firestore
        .collection("brandProfiles")
        .where("verificationStatus", "==", "pending")
        .get();
    firebase_functions_1.logger.info(`findReminderCandidates: ${brandSnap.size} brandProfiles pending`);
    for (const doc of brandSnap.docs) {
        const data = doc.data();
        if (data.reminderSentAt)
            continue;
        const requestedAt = data.verificationRequestedAt ?? null;
        if (requestedAt && requestedAt.toMillis() > threshold.toMillis())
            continue;
        candidates.push({
            id: doc.id,
            kind: "brand",
            label: data.companyName || doc.id,
            waitingSince: requestedAt,
        });
    }
    return candidates;
}
function buildReminderEmailHtml(candidate) {
    const path = candidate.kind === "creator" ? "creators" : "brands";
    const link = `${adminPortalUrl.value()}/${path}/${candidate.id}`;
    const kindLabel = candidate.kind === "creator" ? "Creator" : "Brand";
    const waitedLine = candidate.waitingSince
        ? `has been pending for about ${Math.round((Date.now() - candidate.waitingSince.toMillis()) / 60000)} minutes with no admin decision yet.`
        : "has been pending with no admin decision yet.";
    return (0, emailTemplate_1.wrapEmailHtml)(`
    <p style="font-size: 16px; font-weight: 600; margin: 0 0 12px;">
      ${kindLabel} profile waiting on review
    </p>
    <p style="margin: 0 0 16px;">
      <strong>${(0, emailTemplate_1.escapeHtml)(candidate.label)}</strong> ${waitedLine}
    </p>
    <a href="${link}"
       style="display: inline-block; background: #F97316; color: #ffffff; text-decoration: none; padding: 10px 20px; border-radius: 8px; font-weight: 600;">
      Review this profile
    </a>
    <p style="margin: 16px 0 0; font-size: 13px; color: #6b7280;">
      ${(0, emailTemplate_1.escapeHtml)(link)}
    </p>
  `);
}
async function sendReminder(candidate) {
    const kindLabel = candidate.kind === "creator" ? "Creator" : "Brand";
    return (0, sendEmail_1.sendEmail)({
        to: REMINDER_RECIPIENT,
        subject: `${kindLabel} profile pending review: ${candidate.label}`,
        html: buildReminderEmailHtml(candidate),
    });
}
/** Runs every 5 minutes so the 15-minute SLA is never missed by more than a
 * few minutes; cheap to run this often since a quiet queue is just two
 * Firestore reads. */
exports.remindPendingVerifications = (0, scheduler_1.onSchedule)("every 5 minutes", async () => {
    const firestore = (0, firestore_1.getFirestore)();
    const threshold = firestore_1.Timestamp.fromMillis(Date.now() - REMINDER_THRESHOLD_MINUTES * 60 * 1000);
    const candidates = await findReminderCandidates(threshold);
    firebase_functions_1.logger.info(`remindPendingVerifications: ${candidates.length} candidate(s) this run`, { candidates: candidates.map((c) => ({ id: c.id, kind: c.kind, waitingSince: c.waitingSince?.toDate() ?? null })) });
    if (candidates.length === 0)
        return;
    for (const candidate of candidates) {
        const sent = await sendReminder(candidate);
        if (!sent) {
            firebase_functions_1.logger.error(`Failed to send verification reminder for ${candidate.kind} ${candidate.id}`);
            continue;
        }
        const collection = candidate.kind === "creator" ? "creatorProfiles" : "brandProfiles";
        await firestore.collection(collection).doc(candidate.id).set({
            reminderSentAt: firestore_1.Timestamp.now(),
            // Backlog profile from before this feature existed — give it a
            // real stamp now so every future read of this doc has one,
            // instead of relying on this function's "missing = overdue"
            // fallback forever.
            ...(candidate.waitingSince ? {} : { verificationRequestedAt: firestore_1.Timestamp.now() }),
        }, { merge: true });
    }
});
