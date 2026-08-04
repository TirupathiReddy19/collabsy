"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendPushOnAnnouncementCreate = void 0;
const firestore_1 = require("firebase-admin/firestore");
const messaging_1 = require("firebase-admin/messaging");
const firestore_2 = require("firebase-functions/v2/firestore");
const firebase_functions_1 = require("firebase-functions");
const FCM_MULTICAST_LIMIT = 500;
function chunk(items, size) {
    const chunks = [];
    for (let i = 0; i < items.length; i += size) {
        chunks.push(items.slice(i, i + size));
    }
    return chunks;
}
/**
 * Given the base role-matched `users` snapshot, narrows it down further per
 * the announcement's `targetType` — re-derived here (not trusted from the
 * client) the same way the role filter above already is, so a targeted
 * broadcast can't over-deliver just because of what the client happened to
 * compute. Returns the subset of `usersSnapshot.docs` that also match.
 */
async function filterByTarget(announcement, usersSnapshot) {
    const targetType = announcement.targetType ?? "all";
    if (targetType === "all")
        return usersSnapshot.docs;
    const firestore = (0, firestore_1.getFirestore)();
    if (targetType === "creator") {
        const targetCreatorId = announcement.targetCreatorId;
        if (!targetCreatorId)
            return [];
        return usersSnapshot.docs.filter((doc) => doc.id === targetCreatorId);
    }
    if (targetType === "brand") {
        const targetBrandId = announcement.targetBrandId;
        if (!targetBrandId)
            return [];
        return usersSnapshot.docs.filter((doc) => doc.id === targetBrandId);
    }
    if (targetType === "category") {
        const categories = announcement.targetCategories ?? [];
        if (categories.length === 0)
            return [];
        // Reused for both Creator "content category" and Brand "industry" —
        // same field, different collection to match against depending on which
        // audience this broadcast is for.
        const collectionName = announcement.audience === "brand" ? "brandProfiles" : "creatorProfiles";
        const matchingUids = new Set();
        // `array-contains-any` caps at 10 values per query.
        for (const batch of chunk(categories, 10)) {
            const snapshot = await firestore
                .collection(collectionName)
                .where("categories", "array-contains-any", batch)
                .get();
            snapshot.docs.forEach((doc) => matchingUids.add(doc.id));
        }
        return usersSnapshot.docs.filter((doc) => matchingUids.has(doc.id));
    }
    if (targetType === "followerRange") {
        const min = announcement.targetMinFollowers;
        const max = announcement.targetMaxFollowers;
        let query = firestore.collection("instagram_accounts");
        if (min != null)
            query = query.where("followersCount", ">=", min);
        if (max != null)
            query = query.where("followersCount", "<=", max);
        const snapshot = await query.get();
        const matchingUids = new Set(snapshot.docs.map((doc) => doc.id));
        return usersSnapshot.docs.filter((doc) => matchingUids.has(doc.id));
    }
    if (targetType === "companySize") {
        const size = announcement.targetCompanySize;
        if (!size)
            return usersSnapshot.docs;
        const snapshot = await firestore
            .collection("brandProfiles")
            .where("companySize", "==", size)
            .get();
        const matchingUids = new Set(snapshot.docs.map((doc) => doc.id));
        return usersSnapshot.docs.filter((doc) => matchingUids.has(doc.id));
    }
    return usersSnapshot.docs;
}
/**
 * Sends a push notification to every user in a broadcast's audience whenever
 * an `announcements/{id}` document is created. Unlike
 * `sendPushOnNotificationCreate` (one recipient per doc), a single broadcast
 * doc fans out to potentially many device tokens, so this uses
 * `sendEachForMulticast` in batches of 500 (FCM's per-call limit) instead of
 * a single `send()`.
 */
exports.sendPushOnAnnouncementCreate = (0, firestore_2.onDocumentCreated)("announcements/{announcementId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot)
        return;
    const announcement = snapshot.data();
    const audience = announcement.audience;
    if (!audience)
        return;
    const firestore = (0, firestore_1.getFirestore)();
    let usersQuery = firestore.collection("users");
    if (audience !== "all") {
        usersQuery = usersQuery.where("role", "==", audience);
    }
    const usersSnapshot = await usersQuery.get();
    const targetedDocs = await filterByTarget(announcement, usersSnapshot);
    const tokens = [];
    for (const doc of targetedDocs) {
        const user = doc.data();
        if (user.pushNotificationsEnabled === false)
            continue;
        const token = user.fcmToken;
        if (token)
            tokens.push(token);
    }
    if (tokens.length === 0)
        return;
    const title = announcement.title ?? "Collabsy";
    const body = announcement.body ?? "";
    for (const batch of chunk(tokens, FCM_MULTICAST_LIMIT)) {
        try {
            await (0, messaging_1.getMessaging)().sendEachForMulticast({
                tokens: batch,
                notification: { title, body },
                data: { referenceType: "announcement", referenceId: "" },
            });
        }
        catch (error) {
            firebase_functions_1.logger.error("Failed to send broadcast push batch", error);
        }
    }
});
