"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CREATOR_WELCOME = exports.BRAND_WELCOME = exports.onBrandApproved = exports.onCreatorApproved = void 0;
exports.sendWelcomeIfNeeded = sendWelcomeIfNeeded;
const firestore_1 = require("firebase-admin/firestore");
const firestore_2 = require("firebase-functions/v2/firestore");
const CREATOR_WELCOME = {
    title: "Welcome to Collabsy! 🎉",
    body: "Your profile is live and ready to go. Explore open campaigns, " +
        "discover exciting opportunities, and apply to brands looking for " +
        "creators like you.",
};
exports.CREATOR_WELCOME = CREATOR_WELCOME;
const BRAND_WELCOME = {
    title: "Welcome to Collabsy! 🎉",
    body: "Your profile is live and ready to go. Head to Discover to find the " +
        "right creators and start building your next campaign.",
};
exports.BRAND_WELCOME = BRAND_WELCOME;
/** Delivered as a targeted broadcast (`announcements`), not a private
 * `notifications` entry — this is what makes it show up as a "Collabsy
 * Team" message in the Messages tab (see AnnouncementsScreen) rather than
 * in the Notifications feed, and it's also what `sendPushOnAnnouncementCreate`
 * already knows how to push to just one specific recipient via
 * targetType/targetCreatorId/targetBrandId — no changes needed there.
 *
 * Guards against sending the same welcome twice — both the real-time
 * trigger and the manual backfill (`backfillWelcomeMessages`) go through
 * this, so re-running the backfill or a rare duplicate function
 * invocation can never double-send. `isWelcomeMessage` is an extra field
 * beyond what the Announcement model declares — safe, since
 * json_serializable/freezed's generated fromJson ignores unrecognized
 * keys rather than rejecting them (unlike the strict enum decoding that
 * broke `notifications.type` earlier).
 */
async function sendWelcomeIfNeeded(userId, audience, welcome) {
    const db = (0, firestore_1.getFirestore)();
    const targetField = audience === "creator" ? "targetCreatorId" : "targetBrandId";
    const existing = await db
        .collection("announcements")
        .where("isWelcomeMessage", "==", true)
        .where(targetField, "==", userId)
        .limit(1)
        .get();
    if (!existing.empty)
        return false;
    await db.collection("announcements").add({
        title: welcome.title,
        body: welcome.body,
        audience,
        createdBy: "system",
        createdAt: firestore_1.Timestamp.now(),
        targetType: audience,
        [targetField]: userId,
        isWelcomeMessage: true,
    });
    return true;
}
/** Fires the instant a creator's verificationStatus flips to 'approved',
 * from any admin screen/path that does it — not tied to one specific
 * button, so it can never be missed by adding the approval flow somewhere
 * new later. */
exports.onCreatorApproved = (0, firestore_2.onDocumentUpdated)("creatorProfiles/{userId}", async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!after || before?.verificationStatus === after.verificationStatus)
        return;
    if (after.verificationStatus !== "approved")
        return;
    await sendWelcomeIfNeeded(event.params.userId, "creator", CREATOR_WELCOME);
});
exports.onBrandApproved = (0, firestore_2.onDocumentUpdated)("brandProfiles/{userId}", async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!after || before?.verificationStatus === after.verificationStatus)
        return;
    if (after.verificationStatus !== "approved")
        return;
    await sendWelcomeIfNeeded(event.params.userId, "brand", BRAND_WELCOME);
});
