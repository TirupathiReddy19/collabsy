"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.appendToSentFolder = appendToSentFolder;
const imapflow_1 = require("imapflow");
const firebase_functions_1 = require("firebase-functions");
/**
 * Appends a raw RFC 822 message to the mailbox's own "Sent" folder over
 * IMAP — sending through raw SMTP (as `sendBrandProspectEmail` does)
 * delivers the message but, unlike a webmail client's own compose flow,
 * never saves a copy anywhere; IMAP's APPEND is the only way to put one
 * there after the fact. Looks the folder up by its `\Sent` special-use
 * attribute rather than assuming a name, since that's server-configured.
 * Best-effort: the send itself already succeeded by the time this runs, so
 * a failure here (wrong IMAP port, folder not flagged, transient network
 * issue) only logs — it must never turn an already-sent email into a
 * reported failure.
 */
async function appendToSentFolder(params) {
    const client = new imapflow_1.ImapFlow({
        host: params.host,
        port: 993,
        secure: true,
        auth: { user: params.email, pass: params.password },
        logger: false,
    });
    try {
        await client.connect();
        const mailboxes = await client.list();
        const sent = mailboxes.find((box) => box.specialUse === "\\Sent") ??
            mailboxes.find((box) => box.name.toLowerCase() === "sent");
        if (!sent) {
            firebase_functions_1.logger.warn("No Sent-folder found via IMAP for brand prospect email copy", {
                mailboxes: mailboxes.map((box) => box.path),
            });
            return;
        }
        await client.append(sent.path, params.rawMessage, ["\\Seen"]);
    }
    catch (error) {
        firebase_functions_1.logger.warn("Failed to save a Sent-folder copy for a brand prospect email", error);
    }
    finally {
        await client.logout().catch(() => undefined);
    }
}
