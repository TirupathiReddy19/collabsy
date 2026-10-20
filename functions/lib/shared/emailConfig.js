"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.smtpFrom = exports.smtpPassword = exports.smtpUser = exports.smtpPort = exports.smtpHost = void 0;
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
