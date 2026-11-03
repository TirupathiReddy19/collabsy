"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getBrandMailboxStatus = void 0;
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const adminAuth_1 = require("../shared/adminAuth");
/**
 * Whether the caller has already connected a mail.collabsy.online mailbox
 * (see `connectBrandMailbox.ts`) — the brand-intern compose dialog checks
 * this before offering to send, since `brandMailCredentials/{uid}` itself is
 * unreadable to every client. Only ever returns the email, never the stored
 * password.
 */
exports.getBrandMailboxStatus = (0, https_1.onCall)(async (request) => {
    await (0, adminAuth_1.requireAdminOrPermission)(request, "/brand-outreach-leads");
    const doc = await (0, firestore_1.getFirestore)()
        .collection("brandMailCredentials")
        .doc(request.auth.uid)
        .get();
    return { email: doc.data()?.email ?? null };
});
