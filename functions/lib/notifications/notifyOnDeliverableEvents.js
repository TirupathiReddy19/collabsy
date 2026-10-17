"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onDeliverableStatusChanged = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const firestore_2 = require("firebase-admin/firestore");
const createNotificationIfNew_1 = require("./createNotificationIfNew");
/** Mirrors the submit/approve notifications previously sent from
 * `creator_campaign_detail_screen.dart` and `brand_campaign_detail_screen.dart`.
 * Deliverables don't carry the campaign title themselves, so this reads it
 * off the campaign doc — same lookup the client screens already did via
 * their own campaign provider. */
exports.onDeliverableStatusChanged = (0, firestore_1.onDocumentUpdated)("deliverables/{deliverableId}", async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!after || !before || before.status === after.status)
        return;
    if (after.status !== "submitted" && after.status !== "approved")
        return;
    const campaignDoc = await (0, firestore_2.getFirestore)()
        .collection("campaigns")
        .doc(after.campaignId)
        .get();
    const campaignTitle = campaignDoc.data()?.title ?? "your campaign";
    if (after.status === "submitted") {
        await (0, createNotificationIfNew_1.createNotificationIfNew)({
            userId: after.brandId,
            type: "deliverableSubmitted",
            title: "Deliverable submitted",
            body: `${after.creatorName} submitted their deliverable for ${campaignTitle}`,
            referenceType: "campaign",
            referenceId: after.campaignId,
        });
        return;
    }
    await (0, createNotificationIfNew_1.createNotificationIfNew)({
        userId: after.creatorId,
        type: "deliverableApproved",
        title: "Deliverable approved",
        body: `Your deliverable for ${campaignTitle} was approved!`,
        referenceType: "campaign",
        referenceId: after.campaignId,
    });
});
