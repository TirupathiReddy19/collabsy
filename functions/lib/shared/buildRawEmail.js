"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildRawEmail = buildRawEmail;
// MailComposer has no published types; it's nodemailer's own internal
// message builder, used so the exact same raw MIME bytes sent over SMTP
// are also what gets appended to a Sent folder afterward (see
// `appendSentCopy.ts`) or reused across a batched send (see
// `sendBrandProspectMassEmail.ts`).
// eslint-disable-next-line @typescript-eslint/no-var-requires
const MailComposer = require("nodemailer/lib/mail-composer");
/** Builds a raw RFC 822 message from nodemailer-style mail options.
 * build() is callback-style — there's no promise-returning variant. */
function buildRawEmail(mailOptions) {
    return new Promise((resolve, reject) => {
        new MailComposer(mailOptions)
            .compile()
            .build((error, message) => error ? reject(error) : resolve(message));
    });
}
