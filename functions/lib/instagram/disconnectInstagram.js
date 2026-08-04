"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.disconnectInstagram = void 0;
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const firestoreHelpers_1 = require("./firestoreHelpers");
/** Deletes the stored token and marks the account disconnected. Also
 * deletes the synced media docs — they're meaningless once disconnected
 * and would otherwise sit stale in Firestore. */
exports.disconnectInstagram = (0, https_1.onCall)(async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
        throw new https_1.HttpsError("unauthenticated", "Sign in required.");
    }
    await (0, firestoreHelpers_1.tokensDoc)(uid)
        .delete()
        .catch(() => undefined);
    await (0, firestoreHelpers_1.accountDoc)(uid).set({ status: "disconnected" }, { merge: true });
    const firestore = (0, firestore_1.getFirestore)();
    const mediaSnapshot = await firestore
        .collection("instagram_media")
        .where("userId", "==", uid)
        .get();
    const batch = firestore.batch();
    mediaSnapshot.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    return { success: true };
});
