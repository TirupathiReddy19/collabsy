"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendBrandProspectMassEmail = void 0;
const nodemailer_1 = __importDefault(require("nodemailer"));
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const adminAuth_1 = require("../shared/adminAuth");
const emailConfig_1 = require("../shared/emailConfig");
const mailCredentialCrypto_1 = require("../shared/mailCredentialCrypto");
const emailTemplate_1 = require("../shared/emailTemplate");
const appendSentCopy_1 = require("../shared/appendSentCopy");
const buildRawEmail_1 = require("../shared/buildRawEmail");
/** Recipients per SMTP submission — a single message with hundreds of Bcc
 * addresses risks tripping the mail server's own spam/rate heuristics, so
 * a large batch goes out as several smaller messages instead. */
const RECIPIENTS_PER_MESSAGE = 50;
/**
 * Sends one email to every prospect assigned to the calling intern, all in
 * Bcc so recipients never see each other's address. Unlike
 * `sendBrandProspectEmail` (one prospect, a client-supplied To), this
 * always reads its own recipient list from `brandProspects` — the client
 * only supplies subject/body, never who it goes to, since trusting a
 * client-sent recipient list would let a compromised client blast anyone.
 * Marks every included prospect `contacted` afterward (same one-way
 * self-report `markContacted` already does per prospect, just bulk), and
 * separately stamps `massEmailSentAt` on every recipient regardless of
 * prior `contacted` state — that field exists specifically to answer "was
 * this prospect in a bulk send", which `contacted` alone can't (it's also
 * set by the single-send button and a manual mark).
 */
exports.sendBrandProspectMassEmail = (0, https_1.onCall)({
    secrets: [emailConfig_1.smtpHost, emailConfig_1.smtpPort, emailConfig_1.mailCredentialEncryptionKey],
    timeoutSeconds: 540,
}, async (request) => {
    await (0, adminAuth_1.requireAdminOrPermission)(request, "/brand-outreach-leads");
    const uid = request.auth.uid;
    const data = request.data;
    if (!data?.subject?.trim() || !data?.body?.trim()) {
        throw new https_1.HttpsError("invalid-argument", "subject and body are required.");
    }
    const firestore = (0, firestore_1.getFirestore)();
    const credDoc = await firestore.collection("brandMailCredentials").doc(uid).get();
    const creds = credDoc.data();
    if (!creds?.email || !creds?.encryptedPassword) {
        throw new https_1.HttpsError("failed-precondition", "Connect your mailbox before sending.");
    }
    const email = creds.email;
    const password = (0, mailCredentialCrypto_1.decryptMailPassword)(creds.encryptedPassword);
    const prospectsSnapshot = await firestore
        .collection("brandProspects")
        .where("assignedTo", "==", uid)
        .get();
    const recipients = [];
    for (const doc of prospectsSnapshot.docs) {
        const prospectEmails = doc.data().emails ?? [];
        if (prospectEmails.length === 0)
            continue;
        recipients.push({
            docId: doc.id,
            address: prospectEmails[0],
            alreadyContacted: doc.data().contacted === true,
        });
    }
    if (recipients.length === 0) {
        throw new https_1.HttpsError("failed-precondition", "None of your prospects have an email on file.");
    }
    const transporter = nodemailer_1.default.createTransport({
        host: emailConfig_1.smtpHost.value(),
        port: Number(emailConfig_1.smtpPort.value()),
        secure: Number(emailConfig_1.smtpPort.value()) === 465,
        auth: { user: email, pass: password },
    });
    const html = (0, emailTemplate_1.escapeHtml)(data.body).replace(/\n/g, "<br>");
    for (let start = 0; start < recipients.length; start += RECIPIENTS_PER_MESSAGE) {
        const addresses = recipients
            .slice(start, start + RECIPIENTS_PER_MESSAGE)
            .map((r) => r.address);
        const rawMessage = await (0, buildRawEmail_1.buildRawEmail)({
            // A Bcc-only blast still needs a visible To; sending to yourself
            // keeps every real recipient hidden, same idea as
            // "undisclosed-recipients".
            from: email,
            to: email,
            bcc: addresses,
            subject: data.subject,
            text: data.body,
            html,
        });
        try {
            await transporter.sendMail({
                raw: rawMessage,
                envelope: { from: email, to: [...addresses, emailConfig_1.brandOutreachOversightBcc] },
            });
        }
        catch {
            throw new https_1.HttpsError("internal", `Failed partway through sending (batch starting at recipient ${start + 1} ` +
                "of " + recipients.length + ") - your mailbox connection may have " +
                "expired. Try reconnecting; prospects already emailed are still marked contacted.");
        }
        await (0, appendSentCopy_1.appendToSentFolder)({ host: emailConfig_1.smtpHost.value(), email, password, rawMessage });
        // Marked right after this batch's send succeeds, not at the very
        // end — if a later batch's send then fails, the error above can
        // honestly say earlier recipients are already marked, and a retry
        // won't double-email anyone who already went out.
        const batchRecipients = recipients.slice(start, start + RECIPIENTS_PER_MESSAGE);
        const sentAt = firestore_1.Timestamp.now();
        const writeBatch = firestore.batch();
        for (const recipient of batchRecipients) {
            const update = { massEmailSentAt: sentAt };
            if (!recipient.alreadyContacted) {
                update.contacted = true;
                update.contactedAt = sentAt;
            }
            writeBatch.update(firestore.collection("brandProspects").doc(recipient.docId), update);
        }
        await writeBatch.commit();
    }
    return { sent: recipients.length };
});
