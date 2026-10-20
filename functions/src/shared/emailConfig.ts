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
