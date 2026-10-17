"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onApplicationStatusChanged = exports.onApplicationCreated = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const createNotificationIfNew_1 = require("./createNotificationIfNew");
/** Mirrors `campaigns_providers.dart`'s `applyToCampaign` notification —
 * same title/body so this is a no-op swap for anyone already on it. */
exports.onApplicationCreated = (0, firestore_1.onDocumentCreated)("applications/{applicationId}", async (event) => {
    const application = event.data?.data();
    if (!application || application.status !== "pending")
        return;
    await (0, createNotificationIfNew_1.createNotificationIfNew)({
        userId: application.brandId,
        type: "newApplication",
        title: "New application",
        body: `${application.creatorName} applied to ${application.campaignTitle}`,
        referenceType: "campaign",
        referenceId: application.campaignId,
    });
});
/** Mirrors the three status-transition notifications previously sent from
 * `campaigns_providers.dart` (withdraw) and `brand_campaign_detail_screen.dart`
 * (accept/reject). */
exports.onApplicationStatusChanged = (0, firestore_1.onDocumentUpdated)("applications/{applicationId}", async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!after || !before || before.status === after.status)
        return;
    switch (after.status) {
        case "withdrawn":
            await (0, createNotificationIfNew_1.createNotificationIfNew)({
                userId: after.brandId,
                type: "applicationWithdrawn",
                title: "Application withdrawn",
                body: `${after.creatorName} withdrew their application to ${after.campaignTitle}`,
                referenceType: "campaign",
                referenceId: after.campaignId,
            });
            return;
        case "accepted":
            await (0, createNotificationIfNew_1.createNotificationIfNew)({
                userId: after.creatorId,
                type: "applicationAccepted",
                title: "Application accepted",
                body: `You've been accepted for ${after.campaignTitle}`,
                referenceType: "campaign",
                referenceId: after.campaignId,
            });
            return;
        case "rejected":
            await (0, createNotificationIfNew_1.createNotificationIfNew)({
                userId: after.creatorId,
                type: "applicationRejected",
                title: "Application update",
                body: `Your application for ${after.campaignTitle} wasn't accepted this time`,
                referenceType: "campaign",
                referenceId: after.campaignId,
            });
            return;
        default:
            return;
    }
});
