"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.mailCredentialEncryptionKey = exports.smtpFrom = exports.smtpPassword = exports.smtpUser = exports.smtpPort = exports.smtpHost = void 0;
const params_1 = require("firebase-functions/params");
/** Modoboa SMTP credentials for the sending mailbox (e.g.
 * notifications@collabsy.online). Set via:
 *   firebase functions:secrets:set SMTP_HOST
 *   firebase functions:secrets:set SMTP_PORT
 *   firebase functions:secrets:set SMTP_USER
 *   firebase functions:secrets:set SMTP_PASSWORD
 * Never committed, never sent to the client. */
exports.smtpHost = (0, params_1.defineSecret)("SMTP_HOST");
exports.smtpPort = (0, params_1.defineSecret)("SMTP_PORT");
exports.smtpUser = (0, params_1.defineSecret)("SMTP_USER");
exports.smtpPassword = (0, params_1.defineSecret)("SMTP_PASSWORD");
/** The address shown in the "From" header — not sensitive, so a regular
 * param rather than a secret. Defaults to the sending mailbox itself if
 * never set. */
exports.smtpFrom = (0, params_1.defineString)("SMTP_FROM", { default: "" });
/** 32-byte (base64-encoded) AES-256-GCM key used only to encrypt/decrypt the
 * per-intern mailbox passwords stored in `brandMailCredentials/{uid}` (see
 * `mailCredentialCrypto.ts`) — a different secret from the SMTP_* ones above
 * since those authenticate Collabsy's own shared mailbox, not an intern's.
 * Set via:
 *   firebase functions:secrets:set MAIL_CREDENTIAL_ENC_KEY
 * Generate one with: node -e "console.log(require('crypto').randomBytes(32).toString('base64'))" */
exports.mailCredentialEncryptionKey = (0, params_1.defineSecret)("MAIL_CREDENTIAL_ENC_KEY");
