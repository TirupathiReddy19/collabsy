"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getFcmToken = getFcmToken;
const firestore_1 = require("firebase-admin/firestore");
/**
 * U1 phase A: fcmToken is moving from the public `users/{uid}` doc to
 * `users/{uid}/private/contact`, written by both locations during the
 * transition (AuthRepository dual-writes; backfillPrivateContact covers
 * existing accounts). Reads the new location first and falls back to the
 * old public field — covers the narrow window on a freshly-updated account
 * before the backfill has run, or before this account's own device has
 * triggered a fresh token write. Safe to drop once phase B removes the
 * public field for good.
 */
async function getFcmToken(uid) {
    const firestore = (0, firestore_1.getFirestore)();
    const privateDoc = await firestore
        .collection("users")
        .doc(uid)
        .collection("private")
        .doc("contact")
        .get();
    const privateToken = privateDoc.data()?.fcmToken;
    if (privateToken)
        return privateToken;
    const publicDoc = await firestore.collection("users").doc(uid).get();
    return publicDoc.data()?.fcmToken;
}
