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
/**
 * Sends a brand-prospect outreach email through the calling intern's own
 * connected mailbox (see `connectBrandMailbox.ts`) — the recipient sees it
 * arrive from the intern's real mail.collabsy.online address, not a shared
 * account, and it lands in that intern's own Sent folder since it goes out
 * over their own SMTP login. Unlike `sendEmail.ts`'s best-effort notification
 * sender, this function's entire job IS the send, so a failure throws
 * instead of swallowing silently.
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
    const transporter = nodemailer_1.default.createTransport({
        host: emailConfig_1.smtpHost.value(),
        port: Number(emailConfig_1.smtpPort.value()),
        secure: Number(emailConfig_1.smtpPort.value()) === 465,
        auth: {
            user: creds.email,
            pass: (0, mailCredentialCrypto_1.decryptMailPassword)(creds.encryptedPassword),
        },
    });
    const html = (0, emailTemplate_1.escapeHtml)(data.body).replace(/\n/g, "<br>");
    try {
        await transporter.sendMail({
            from: creds.email,
            to: data.to,
            subject: data.subject,
            text: data.body,
            html,
        });
    }
    catch {
        throw new https_1.HttpsError("internal", "Failed to send — your mailbox connection may have expired. Try reconnecting.");
    }
    return { success: true };
});
