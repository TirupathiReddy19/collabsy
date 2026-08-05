"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.refreshConnectedInstagramProfiles = void 0;
const firestore_1 = require("firebase-admin/firestore");
const firebase_functions_1 = require("firebase-functions");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const firestoreHelpers_1 = require("./firestoreHelpers");
const instagramApiService_1 = require("./instagramApiService");
/** Keeps every connected creator's follower/media counts, name, bio, and
 * profile picture reasonably fresh in the background — runs whether or
 * not anyone has the app open, so a Brand looking at a creator's profile
 * always sees recent numbers instead of whatever was true the last time
 * that creator happened to open Connected Accounts. `saveProfile` already
 * stamps `lastSyncedAt`, which is what the "Last synced" line in
 * Connected Accounts reads.
 *
 * Deliberately tolerant of failure: unlike `refreshExpiringInstagramTokens`
 * (whose whole job IS to catch a token that's about to become
 * unrefreshable), a single failed sync here is most likely a transient
 * network/API hiccup — it just logs and moves on to retry in 2 hours,
 * rather than flipping the account to "expired" and kicking the creator
 * back to a "reconnect" state over what might just be a blip. */
exports.refreshConnectedInstagramProfiles = (0, scheduler_1.onSchedule)("every 2 hours", async () => {
    const firestore = (0, firestore_1.getFirestore)();
    const snapshot = await firestore
        .collection("instagram_accounts")
        .where("status", "==", "connected")
        .get();
    for (const doc of snapshot.docs) {
        const userId = doc.id;
        try {
            const tokenSnapshot = await (0, firestoreHelpers_1.tokensDoc)(userId).get();
            const accessToken = tokenSnapshot.data()?.accessToken;
            if (!accessToken)
                continue;
            const profile = await (0, instagramApiService_1.fetchProfile)(accessToken);
            await (0, firestoreHelpers_1.saveProfile)(userId, profile);
        }
        catch (error) {
            firebase_functions_1.logger.error("Skipped a connected-profile refresh", {
                userId,
                error,
            });
        }
    }
});
