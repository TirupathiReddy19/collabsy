"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.connectBrandMailbox = void 0;
const nodemailer_1 = __importDefault(require("nodemailer"));
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const adminAuth_1 = require("../shared/adminAuth");
const emailConfig_1 = require("../shared/emailConfig");
const mailCredentialCrypto_1 = require("../shared/mailCredentialCrypto");
/**
 * Verifies a brand intern's own mail.collabsy.online mailbox login against
 * the real SMTP server, then stores it (password encrypted, see
 * `mailCredentialCrypto.ts`) in `brandMailCredentials/{uid}` — a collection
 * `firestore.rules` closes to every client, so only `sendBrandProspectEmail`
 * (via the Admin SDK) can ever read it back. Outreach emails send through
 * this connected mailbox directly, so the recipient sees them come from the
 * intern's own real address, not a shared account.
 */
exports.connectBrandMailbox = (0, https_1.onCall)({ secrets: [emailConfig_1.smtpHost, emailConfig_1.smtpPort, emailConfig_1.mailCredentialEncryptionKey] }, async (request) => {
    await (0, adminAuth_1.requireAdminOrPermission)(request, "/brand-outreach-leads");
    const data = request.data;
    if (!data?.email?.includes("@") || !data?.password) {
        throw new https_1.HttpsError("invalid-argument", "A valid email and password are required.");
    }
    const transporter = nodemailer_1.default.createTransport({
        host: emailConfig_1.smtpHost.value(),
        port: Number(emailConfig_1.smtpPort.value()),
        secure: Number(emailConfig_1.smtpPort.value()) === 465,
        auth: { user: data.email, pass: data.password },
    });
    try {
        await transporter.verify();
    }
    catch {
        throw new https_1.HttpsError("invalid-argument", "Could not sign in with that email and password.");
    }
    await (0, firestore_1.getFirestore)()
        .collection("brandMailCredentials")
        .doc(request.auth.uid)
        .set({
        email: data.email,
        encryptedPassword: (0, mailCredentialCrypto_1.encryptMailPassword)(data.password),
        connectedAt: firestore_1.Timestamp.now(),
    });
    return { email: data.email };
});
