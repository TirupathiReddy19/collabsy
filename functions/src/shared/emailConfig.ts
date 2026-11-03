import { defineSecret, defineString } from "firebase-functions/params";

/** Modoboa SMTP credentials for the sending mailbox (e.g.
 * notifications@collabsy.online). Set via:
 *   firebase functions:secrets:set SMTP_HOST
 *   firebase functions:secrets:set SMTP_PORT
 *   firebase functions:secrets:set SMTP_USER
 *   firebase functions:secrets:set SMTP_PASSWORD
 * Never committed, never sent to the client. */
export const smtpHost = defineSecret("SMTP_HOST");
export const smtpPort = defineSecret("SMTP_PORT");
export const smtpUser = defineSecret("SMTP_USER");
export const smtpPassword = defineSecret("SMTP_PASSWORD");

/** The address shown in the "From" header — not sensitive, so a regular
 * param rather than a secret. Defaults to the sending mailbox itself if
 * never set. */
export const smtpFrom = defineString("SMTP_FROM", { default: "" });

/** 32-byte (base64-encoded) AES-256-GCM key used only to encrypt/decrypt the
 * per-intern mailbox passwords stored in `brandMailCredentials/{uid}` (see
 * `mailCredentialCrypto.ts`) — a different secret from the SMTP_* ones above
 * since those authenticate Collabsy's own shared mailbox, not an intern's.
 * Set via:
 *   firebase functions:secrets:set MAIL_CREDENTIAL_ENC_KEY
 * Generate one with: node -e "console.log(require('crypto').randomBytes(32).toString('base64'))" */
export const mailCredentialEncryptionKey = defineSecret("MAIL_CREDENTIAL_ENC_KEY");
