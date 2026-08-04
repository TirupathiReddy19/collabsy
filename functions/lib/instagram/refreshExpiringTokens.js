"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.refreshExpiringInstagramTokens = void 0;
const firestore_1 = require("firebase-admin/firestore");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const firestoreHelpers_1 = require("./firestoreHelpers");
const instagramApiService_1 = require("./instagramApiService");
/** Runs daily. A long-lived Instagram token is only refreshable *before*
 * it expires — once it lapses, the only fix is a full reconnect — so this
 * proactively refreshes anything expiring within 7 days rather than
 * waiting for a creator to happen to open the app right before the
 * 60-day window runs out. */
exports.refreshExpiringInstagramTokens = (0, scheduler_1.onSchedule)("every 24 hours", async () => {
    const firestore = (0, firestore_1.getFirestore)();
    const sevenDaysFromNow = firestore_1.Timestamp.fromMillis(Date.now() + 7 * 24 * 60 * 60 * 1000);
    const snapshot = await firestore
        .collectionGroup("private")
        .where("expiresAt", "<=", sevenDaysFromNow)
        .get();
    for (const doc of snapshot.docs) {
        const userId = doc.ref.parent.parent?.id;
        const accessToken = doc.data().accessToken;
        if (!userId || !accessToken)
            continue;
        try {
            const refreshed = await (0, instagramApiService_1.refreshLongLivedToken)({ accessToken });
            await (0, firestoreHelpers_1.saveTokens)(userId, refreshed);
            const profile = await (0, instagramApiService_1.fetchProfile)(refreshed.access_token);
            await (0, firestoreHelpers_1.saveProfile)(userId, profile);
            const media = await (0, instagramApiService_1.fetchMedia)(refreshed.access_token);
            await (0, firestoreHelpers_1.saveMedia)(userId, media);
        }
        catch (error) {
            await (0, firestoreHelpers_1.markStatus)(userId, "expired");
        }
    }
});
