"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.backfillWelcomeMessages = void 0;
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const adminAuth_1 = require("../shared/adminAuth");
const sendWelcomeMessage_1 = require("./sendWelcomeMessage");
/** One-time catch-up for everyone approved before the welcome-message
 * automation existed — the real-time triggers only fire on a *change* to
 * 'approved', so an account that was already approved needs this instead.
 * Safe to run more than once: `sendWelcomeIfNeeded` skips anyone who
 * already has a welcomeMessage notification. */
exports.backfillWelcomeMessages = (0, https_1.onCall)(async (request) => {
    await (0, adminAuth_1.requireAdminOrPermission)(request, "/analytics");
    const db = (0, firestore_1.getFirestore)();
    let sent = 0;
    const creators = await db
        .collection("creatorProfiles")
        .where("verificationStatus", "==", "approved")
        .get();
    for (const doc of creators.docs) {
        if (await (0, sendWelcomeMessage_1.sendWelcomeIfNeeded)(doc.id, "creator", sendWelcomeMessage_1.CREATOR_WELCOME))
            sent++;
    }
    const brands = await db
        .collection("brandProfiles")
        .where("verificationStatus", "==", "approved")
        .get();
    for (const doc of brands.docs) {
        if (await (0, sendWelcomeMessage_1.sendWelcomeIfNeeded)(doc.id, "brand", sendWelcomeMessage_1.BRAND_WELCOME))
            sent++;
    }
    return { sent };
});
