import nodemailer from "nodemailer";
import { logger } from "firebase-functions";

import { smtpFrom, smtpHost, smtpPassword, smtpPort, smtpUser } from "./emailConfig";

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
export async function sendEmail(options: {
  to: string;
  subject: string;
  html: string;
  /** Replies go here instead of the sending mailbox — e.g. the staff
   * member who triggered the send, so a reply lands with them directly. */
  replyTo?: string;
}): Promise<boolean> {
  try {
    const transporter = nodemailer.createTransport({
      host: smtpHost.value(),
      port: Number(smtpPort.value()),
      // 465 is implicit TLS; 587 (the recommended submission port — 25 is
      // blocked outbound on Cloud Functions' infrastructure) is STARTTLS.
      secure: Number(smtpPort.value()) === 465,
      auth: { user: smtpUser.value(), pass: smtpPassword.value() },
    });

    const from = smtpFrom.value() || smtpUser.value();
    await transporter.sendMail({
      from: `Collabsy <${from}>`,
      to: options.to,
      subject: options.subject,
      html: options.html,
      ...(options.replyTo ? { replyTo: options.replyTo } : {}),
    });
    return true;
  } catch (error) {
    logger.error(`Failed to send email to ${options.to}`, error);
    return false;
  }
}
