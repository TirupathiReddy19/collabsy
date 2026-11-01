"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendEmail = sendEmail;
const nodemailer_1 = __importDefault(require("nodemailer"));
const firebase_functions_1 = require("firebase-functions");
const emailConfig_1 = require("./emailConfig");
/** Generic SMTP sender (Modoboa-hosted mailbox, but works with any SMTP
 * server) — used by the public website forms to notify staff of a new
 * submission and confirm receipt to whoever submitted it, and by
 * `sendBrandProspectEmail` for intern-initiated outreach.
 *
 * Deliberately never throws: a failed email must never take down the
 * Firestore write it's attached to (the form submission itself already
 * succeeded by the time this runs) — logs and returns instead, same
 * "best-effort, non-fatal" shape as this codebase's other side-effects
 * (e.g. dSYM upload, FCM token cleanup on sign-out). Returns whether the
 * send actually succeeded so a caller whose entire job IS the send (unlike
 * the fire-and-forget notification emails) can still surface a failure to
 * its own caller instead of silently reporting success.
 */
async function sendEmail(options) {
    try {
        const transporter = nodemailer_1.default.createTransport({
            host: emailConfig_1.smtpHost.value(),
            port: Number(emailConfig_1.smtpPort.value()),
            // 465 is implicit TLS; 587 (the recommended submission port — 25 is
            // blocked outbound on Cloud Functions' infrastructure) is STARTTLS.
            secure: Number(emailConfig_1.smtpPort.value()) === 465,
            auth: { user: emailConfig_1.smtpUser.value(), pass: emailConfig_1.smtpPassword.value() },
        });
        const from = emailConfig_1.smtpFrom.value() || emailConfig_1.smtpUser.value();
        await transporter.sendMail({
            from: `Collabsy <${from}>`,
            to: options.to,
            subject: options.subject,
            html: options.html,
            ...(options.replyTo ? { replyTo: options.replyTo } : {}),
        });
        return true;
    }
    catch (error) {
        firebase_functions_1.logger.error(`Failed to send email to ${options.to}`, error);
        return false;
    }
}
