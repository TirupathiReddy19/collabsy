"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.backfillPrivateContact = void 0;
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const adminAuth_1 = require("./shared/adminAuth");
/**
 * One-time admin action for U1 phase A: copies every existing `users/{uid}`
 * doc's `email`/`phone`/`fcmToken` into the new `private/contact`
 * (email, fcmToken) and `private/phone` (phone) subdocs those fields are
 * moving to. Needed because an account that doesn't trigger one of
 * AuthRepository's write paths (sign-up, sign-in, phone/email change, token
 * refresh) after updating to build 31+ would otherwise have an empty
 * private doc until it does — this backfills everyone up front instead,
 * mirroring `backfillCreatedAtFromAuth`'s shape. The Admin SDK write here
 * bypasses the rules that limit a client to writing only its own doc, so
 * this is the only way to do all accounts in one pass. Safe to run more
 * than once: it always just re-copies the current public-field values.
 */
exports.backfillPrivateContact = (0, https_1.onCall)(async (request) => {
    (0, adminAuth_1.requireAdmin)(request);
    const firestore = (0, firestore_1.getFirestore)();
    let scanned = 0;
    let updated = 0;
    let pageToken;
    do {
        let query = firestore.collection("users").orderBy("__name__").limit(500);
        if (pageToken)
            query = query.startAfter(pageToken);
        const page = await query.get();
        if (page.empty)
            break;
        let batch = firestore.batch();
        for (const doc of page.docs) {
            scanned++;
            const data = doc.data();
            const email = data.email;
            const phone = data.phone;
            const fcmToken = data.fcmToken;
            if (email === undefined && phone === undefined && fcmToken === undefined) {
                continue;
            }
            if (email !== undefined || fcmToken !== undefined) {
                batch.set(doc.ref.collection("private").doc("contact"), {
                    ...(email !== undefined ? { email } : {}),
                    ...(fcmToken !== undefined ? { fcmToken } : {}),
                }, { merge: true });
            }
            if (phone !== undefined) {
                batch.set(doc.ref.collection("private").doc("phone"), { phone }, { merge: true });
            }
            updated++;
        }
        await batch.commit();
        pageToken = page.docs[page.docs.length - 1];
    } while (true);
    return { scanned, updated };
});
