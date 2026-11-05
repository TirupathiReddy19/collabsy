import nodemailer from "nodemailer";
import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { requireAdminOrPermission } from "../shared/adminAuth";
import { smtpHost, smtpPort, mailCredentialEncryptionKey } from "../shared/emailConfig";
import { decryptMailPassword } from "../shared/mailCredentialCrypto";
import { escapeHtml } from "../shared/emailTemplate";
import { appendToSentFolder } from "../shared/appendSentCopy";

// MailComposer has no published types; it's nodemailer's own internal
// message builder, used here so the exact same raw MIME bytes sent over
// SMTP are also what gets appended to the Sent folder afterward.
// eslint-disable-next-line @typescript-eslint/no-var-requires
const MailComposer = require("nodemailer/lib/mail-composer");

interface SendBrandProspectEmailRequest {
  to: string;
  subject: string;
  body: string;
}

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
export const sendBrandProspectEmail = onCall(
  { secrets: [smtpHost, smtpPort, mailCredentialEncryptionKey] },
  async (request) => {
    await requireAdminOrPermission(request, "/brand-outreach-leads");

    const data = request.data as SendBrandProspectEmailRequest;
    if (!data?.to?.includes("@") || !data?.subject?.trim() || !data?.body?.trim()) {
      throw new HttpsError("invalid-argument", "to, subject, and body are required.");
    }

    const credDoc = await getFirestore()
      .collection("brandMailCredentials")
      .doc(request.auth!.uid)
      .get();
    const creds = credDoc.data();
    if (!creds?.email || !creds?.encryptedPassword) {
      throw new HttpsError(
        "failed-precondition",
        "Connect your mailbox before sending."
      );
    }

    const email = creds.email as string;
    const password = decryptMailPassword(creds.encryptedPassword as string);

    const transporter = nodemailer.createTransport({
      host: smtpHost.value(),
      port: Number(smtpPort.value()),
      secure: Number(smtpPort.value()) === 465,
      auth: { user: email, pass: password },
    });

    const html = escapeHtml(data.body).replace(/\n/g, "<br>");
    const mailOptions = {
      from: email,
      to: data.to,
      subject: data.subject,
      text: data.body,
      html,
    };

    // Built once up front so the exact same raw bytes that go out over
    // SMTP are also what gets appended to Sent afterward. build() is
    // callback-style — there's no promise-returning variant.
    const rawMessage: Buffer = await new Promise((resolve, reject) => {
      new MailComposer(mailOptions)
        .compile()
        .build((error: Error | null, message: Buffer) =>
          error ? reject(error) : resolve(message)
        );
    });

    try {
      await transporter.sendMail({ raw: rawMessage, envelope: { from: email, to: data.to } });
    } catch {
      throw new HttpsError(
        "internal",
        "Failed to send — your mailbox connection may have expired. Try reconnecting."
      );
    }

    await appendToSentFolder({ host: smtpHost.value(), email, password, rawMessage });

    return { success: true };
  }
);
