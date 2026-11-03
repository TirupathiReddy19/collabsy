import nodemailer from "nodemailer";
import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { requireAdminOrPermission } from "../shared/adminAuth";
import { smtpHost, smtpPort } from "../shared/emailConfig";
import { encryptMailPassword } from "../shared/mailCredentialCrypto";

interface ConnectBrandMailboxRequest {
  email: string;
  password: string;
}

/**
 * Verifies a brand intern's own mail.collabsy.online mailbox login against
 * the real SMTP server, then stores it (password encrypted, see
 * `mailCredentialCrypto.ts`) in `brandMailCredentials/{uid}` — a collection
 * `firestore.rules` closes to every client, so only `sendBrandProspectEmail`
 * (via the Admin SDK) can ever read it back. Outreach emails send through
 * this connected mailbox directly, so the recipient sees them come from the
 * intern's own real address, not a shared account.
 */
export const connectBrandMailbox = onCall(
  { secrets: [smtpHost, smtpPort] },
  async (request) => {
    await requireAdminOrPermission(request, "/brand-outreach-leads");

    const data = request.data as ConnectBrandMailboxRequest;
    if (!data?.email?.includes("@") || !data?.password) {
      throw new HttpsError("invalid-argument", "A valid email and password are required.");
    }

    const transporter = nodemailer.createTransport({
      host: smtpHost.value(),
      port: Number(smtpPort.value()),
      secure: Number(smtpPort.value()) === 465,
      auth: { user: data.email, pass: data.password },
    });

    try {
      await transporter.verify();
    } catch {
      throw new HttpsError(
        "invalid-argument",
        "Could not sign in with that email and password."
      );
    }

    await getFirestore()
      .collection("brandMailCredentials")
      .doc(request.auth!.uid)
      .set({
        email: data.email,
        encryptedPassword: encryptMailPassword(data.password),
        connectedAt: Timestamp.now(),
      });

    return { email: data.email };
  }
);
