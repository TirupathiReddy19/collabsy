"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createNotificationIfNew = createNotificationIfNew;
const firestore_1 = require("firebase-admin/firestore");
// How long after an old-build client's own write this trigger still
// recognizes it as "the same event" rather than a new, coincidentally
// identical one (e.g. two separate "ok" chat messages). Generous enough to
// cover any realistic delivery delay between the client's write and this
// trigger firing, tight enough that a genuine repeat sent minutes later
// still gets its own notification.
const DEDUPE_WINDOW_MS = 2 * 60 * 1000;
/**
 * N1 phase A: these events used to be notified client-side (any signed-in
 * user could forge them for anyone — see the `notifications` create rule's
 * history). Real app builds still on 29/23 keep writing their own
 * notification for this same event, so every trigger below has to assume
 * one might already exist and skip creating a second.
 *
 * There's no shared id to dedupe on (the old client write never recorded
 * the application/deliverable/message id), so this matches on
 * (userId, type, referenceId, body) within a short recency window instead
 * — body is unique per real event in practice (it always embeds the
 * actor's name or the message text), and the window keeps a later,
 * coincidentally-identical event (e.g. the same chat text sent again) from
 * being mistaken for the original. Filtering the window in code rather
 * than in the query keeps this to a pure equality query, which Firestore
 * indexes automatically — no composite index to deploy.
 */
async function createNotificationIfNew(input) {
    const db = (0, firestore_1.getFirestore)();
    const existing = await db
        .collection("notifications")
        .where("userId", "==", input.userId)
        .where("type", "==", input.type)
        .where("referenceId", "==", input.referenceId)
        .where("body", "==", input.body)
        .get();
    const now = Date.now();
    const hasRecentDuplicate = existing.docs.some((doc) => {
        const createdAt = doc.data().createdAt;
        if (!createdAt)
            return false;
        return now - createdAt.toMillis() < DEDUPE_WINDOW_MS;
    });
    if (hasRecentDuplicate)
        return false;
    await db.collection("notifications").add({
        userId: input.userId,
        type: input.type,
        title: input.title,
        body: input.body,
        referenceType: input.referenceType,
        referenceId: input.referenceId,
        read: false,
        createdAt: firestore_1.Timestamp.now(),
    });
    return true;
}
