"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.backfillCreatedAtFromAuth = void 0;
const auth_1 = require("firebase-admin/auth");
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const ADMIN_EMAIL = "admin@collabsy.online";
/**
 * One-time admin action: (re)sets `users/{uid}.createdAt` from Firebase
 * Auth's own (real, immutable) `metadata.creationTime` for every account —
 * a bug in `setRole()` meant every password/phone signup never had this
 * field written at all (unlike Google sign-ins), and an earlier client-side
 * stopgap approximated it from `updatedAt` for accounts missing it, which
 * this overwrites with the real value. Only the Admin SDK (server-side,
 * which this function has) can read another user's Auth creation time; the
 * client SDK can only ever see the signed-in user's own.
 */
exports.backfillCreatedAtFromAuth = (0, https_1.onCall)(async (request) => {
    const email = request.auth?.token?.email;
    if (email !== ADMIN_EMAIL) {
        throw new https_1.HttpsError("permission-denied", "Admin only.");
    }
    const firestore = (0, firestore_1.getFirestore)();
    let updated = 0;
    let pageToken;
    do {
        const page = await (0, auth_1.getAuth)().listUsers(1000, pageToken);
        pageToken = page.pageToken;
        const docs = await Promise.all(page.users.map((user) => firestore.collection("users").doc(user.uid).get()));
        let batch = firestore.batch();
        let batchCount = 0;
        for (let i = 0; i < page.users.length; i++) {
            const doc = docs[i];
            if (!doc.exists)
                continue;
            batch.set(doc.ref, { createdAt: firestore_1.Timestamp.fromDate(new Date(page.users[i].metadata.creationTime)) }, { merge: true });
            updated++;
            batchCount++;
            if (batchCount === 500) {
                await batch.commit();
                batch = firestore.batch();
                batchCount = 0;
            }
        }
        if (batchCount > 0)
            await batch.commit();
    } while (pageToken);
    return { updated };
});
