"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendBrandProspectEmail = void 0;
const nodemailer_1 = __importDefault(require("nodemailer"));
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const adminAuth_1 = require("../shared/adminAuth");
const emailConfig_1 = require("../shared/emailConfig");
const mailCredentialCrypto_1 = require("../shared/mailCredentialCrypto");
const emailTemplate_1 = require("../shared/emailTemplate");
const appendSentCopy_1 = require("../shared/appendSentCopy");
const buildRawEmail_1 = require("../shared/buildRawEmail");
/**
 * Sends a brand-prospect outreach email through the calling intern's own
 * connected mailbox (see `connectBrandMailbox.ts`) — the recipient sees it
 * arrive from the intern's real mail.collabsy.online address, not a shared
 * account. A raw SMTP send on its own never leaves a copy anywhere (that's
 * normally a webmail client's own job), so this also appends one to the
 * mailbox's Sent folder over IMAP (best-effort — see `appendSentCopy.ts`)
 * so the intern can actually find what they sent afterward. Unlike
 * `sendEmail.ts`'s best-effort notification sender, the send itself is this
 * function's entire job, so a send failure throws instead of swallowing
 * silently.
 */
exports.sendBrandProspectEmail = (0, https_1.onCall)({ secrets: [emailConfig_1.smtpHost, emailConfig_1.smtpPort, emailConfig_1.mailCredentialEncryptionKey] }, async (request) => {
    await (0, adminAuth_1.requireAdminOrPermission)(request, "/brand-outreach-leads");
    const data = request.data;
    if (!data?.to?.includes("@") || !data?.subject?.trim() || !data?.body?.trim()) {
        throw new https_1.HttpsError("invalid-argument", "to, subject, and body are required.");
    }
    const credDoc = await (0, firestore_1.getFirestore)()
        .collection("brandMailCredentials")
        .doc(request.auth.uid)
        .get();
    const creds = credDoc.data();
    if (!creds?.email || !creds?.encryptedPassword) {
        throw new https_1.HttpsError("failed-precondition", "Connect your mailbox before sending.");
    }
    const email = creds.email;
    const password = (0, mailCredentialCrypto_1.decryptMailPassword)(creds.encryptedPassword);
    const transporter = nodemailer_1.default.createTransport({
        host: emailConfig_1.smtpHost.value(),
        port: Number(emailConfig_1.smtpPort.value()),
        secure: Number(emailConfig_1.smtpPort.value()) === 465,
        auth: { user: email, pass: password },
    });
    const html = (0, emailTemplate_1.escapeHtml)(data.body).replace(/\n/g, "<br>");
    const mailOptions = {
        from: email,
        to: data.to,
        bcc: emailConfig_1.brandOutreachOversightBcc,
        subject: data.subject,
        text: data.body,
        html,
    };
    const rawMessage = await (0, buildRawEmail_1.buildRawEmail)(mailOptions);
    try {
        // `raw` bypasses nodemailer's own envelope computation, so the bcc
        // recipient has to be listed explicitly here too — MailComposer
        // already dropped the "Bcc:" header from rawMessage itself, so the
        // real recipient never sees it in the message they receive.
        await transporter.sendMail({
            raw: rawMessage,
            envelope: { from: email, to: [data.to, emailConfig_1.brandOutreachOversightBcc] },
        });
    }
    catch {
        throw new https_1.HttpsError("internal", "Failed to send — your mailbox connection may have expired. Try reconnecting.");
    }
    await (0, appendSentCopy_1.appendToSentFolder)({ host: emailConfig_1.smtpHost.value(), email, password, rawMessage });
    return { success: true };
});
