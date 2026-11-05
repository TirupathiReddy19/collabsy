import nodemailer from "nodemailer";
import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { requireAdminOrPermission } from "../shared/adminAuth";
import {
  brandOutreachOversightBcc,
  mailCredentialEncryptionKey,
  smtpHost,
  smtpPort,
} from "../shared/emailConfig";
import { decryptMailPassword } from "../shared/mailCredentialCrypto";
import { escapeHtml } from "../shared/emailTemplate";
import { appendToSentFolder } from "../shared/appendSentCopy";
import { buildRawEmail } from "../shared/buildRawEmail";

interface SendBrandProspectMassEmailRequest {
  subject: string;
  body: string;
}

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
export const sendBrandProspectMassEmail = onCall(
  {
    secrets: [smtpHost, smtpPort, mailCredentialEncryptionKey],
    timeoutSeconds: 540,
  },
  async (request) => {
    await requireAdminOrPermission(request, "/brand-outreach-leads");
    const uid = request.auth!.uid;

    const data = request.data as SendBrandProspectMassEmailRequest;
    if (!data?.subject?.trim() || !data?.body?.trim()) {
      throw new HttpsError("invalid-argument", "subject and body are required.");
    }

    const firestore = getFirestore();

    const credDoc = await firestore.collection("brandMailCredentials").doc(uid).get();
    const creds = credDoc.data();
    if (!creds?.email || !creds?.encryptedPassword) {
      throw new HttpsError("failed-precondition", "Connect your mailbox before sending.");
    }
    const email = creds.email as string;
    const password = decryptMailPassword(creds.encryptedPassword as string);

    const prospectsSnapshot = await firestore
      .collection("brandProspects")
      .where("assignedTo", "==", uid)
      .get();

    const recipients: { docId: string; address: string; alreadyContacted: boolean }[] = [];
    for (const doc of prospectsSnapshot.docs) {
      const prospectEmails = (doc.data().emails as string[] | undefined) ?? [];
      if (prospectEmails.length === 0) continue;
      recipients.push({
        docId: doc.id,
        address: prospectEmails[0],
        alreadyContacted: doc.data().contacted === true,
      });
    }

    if (recipients.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "None of your prospects have an email on file."
      );
    }

    const transporter = nodemailer.createTransport({
      host: smtpHost.value(),
      port: Number(smtpPort.value()),
      secure: Number(smtpPort.value()) === 465,
      auth: { user: email, pass: password },
    });

    const html = escapeHtml(data.body).replace(/\n/g, "<br>");

    for (let start = 0; start < recipients.length; start += RECIPIENTS_PER_MESSAGE) {
      const addresses = recipients
        .slice(start, start + RECIPIENTS_PER_MESSAGE)
        .map((r) => r.address);

      const rawMessage = await buildRawEmail({
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
          envelope: { from: email, to: [...addresses, brandOutreachOversightBcc] },
        });
      } catch {
        throw new HttpsError(
          "internal",
          `Failed partway through sending (batch starting at recipient ${start + 1} ` +
            "of " + recipients.length + ") - your mailbox connection may have " +
            "expired. Try reconnecting; prospects already emailed are still marked contacted."
        );
      }

      await appendToSentFolder({ host: smtpHost.value(), email, password, rawMessage });

      // Marked right after this batch's send succeeds, not at the very
      // end — if a later batch's send then fails, the error above can
      // honestly say earlier recipients are already marked, and a retry
      // won't double-email anyone who already went out.
      const batchRecipients = recipients.slice(start, start + RECIPIENTS_PER_MESSAGE);
      const sentAt = Timestamp.now();
      const writeBatch = firestore.batch();
      for (const recipient of batchRecipients) {
        const update: Record<string, unknown> = { massEmailSentAt: sentAt };
        if (!recipient.alreadyContacted) {
          update.contacted = true;
          update.contactedAt = sentAt;
        }
        writeBatch.update(
          firestore.collection("brandProspects").doc(recipient.docId),
          update
        );
      }
      await writeBatch.commit();
    }

    return { sent: recipients.length };
  }
);
