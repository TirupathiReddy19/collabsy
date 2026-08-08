"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.expireCampaigns = void 0;
const firestore_1 = require("firebase-admin/firestore");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const firebase_functions_1 = require("firebase-functions");
/**
 * Flips `active` campaigns whose `endDate` has passed to `expired`, so they
 * stop matching every `status == 'active'` query in the app (the Creator
 * browse tab, admin dashboards, etc) — not just the client-side `isExpired`
 * check the Creator browse tab already applies for same-day accuracy (see
 * `openCampaigns` in campaigns_providers.dart), which this is the slower,
 * authoritative counterpart to.
 */
exports.expireCampaigns = (0, scheduler_1.onSchedule)("every 24 hours", async () => {
    const firestore = (0, firestore_1.getFirestore)();
    const now = firestore_1.Timestamp.now();
    const snapshot = await firestore
        .collection("campaigns")
        .where("status", "==", "active")
        .where("endDate", "<=", now)
        .get();
    if (snapshot.empty)
        return;
    for (let i = 0; i < snapshot.docs.length; i += 500) {
        const batch = firestore.batch();
        for (const doc of snapshot.docs.slice(i, i + 500)) {
            batch.update(doc.ref, { status: "expired" });
        }
        try {
            await batch.commit();
        }
        catch (error) {
            firebase_functions_1.logger.error("expireCampaigns batch commit failed", error);
        }
    }
});
