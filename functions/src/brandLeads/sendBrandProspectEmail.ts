import nodemailer from "nodemailer";
import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { requireAdminOrPermission } from "../shared/adminAuth";
import { smtpHost, smtpPort, mailCredentialEncryptionKey } from "../shared/emailConfig";
import { decryptMailPassword } from "../shared/mailCredentialCrypto";
import { escapeHtml } from "../shared/emailTemplate";

interface SendBrandProspectEmailRequest {
  to: string;
  subject: string;
  body: string;
}

/**
 * Sends a brand-prospect outreach email through the calling intern's own
 * connected mailbox (see `connectBrandMailbox.ts`) — the recipient sees it
 * arrive from the intern's real mail.collabsy.online address, not a shared
 * account, and it lands in that intern's own Sent folder since it goes out
 * over their own SMTP login. Unlike `sendEmail.ts`'s best-effort notification
 * sender, this function's entire job IS the send, so a failure throws
 * instead of swallowing silently.
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

    const transporter = nodemailer.createTransport({
      host: smtpHost.value(),
      port: Number(smtpPort.value()),
      secure: Number(smtpPort.value()) === 465,
      auth: {
        user: creds.email as string,
        pass: decryptMailPassword(creds.encryptedPassword as string),
      },
    });

    const html = escapeHtml(data.body).replace(/\n/g, "<br>");

    try {
      await transporter.sendMail({
        from: creds.email as string,
        to: data.to,
        subject: data.subject,
        text: data.body,
        html,
      });
    } catch {
      throw new HttpsError(
        "internal",
        "Failed to send — your mailbox connection may have expired. Try reconnecting."
      );
    }

    return { success: true };
  }
);
