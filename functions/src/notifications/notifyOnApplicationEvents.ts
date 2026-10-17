import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";

import { createNotificationIfNew } from "./createNotificationIfNew";

/** Mirrors `campaigns_providers.dart`'s `applyToCampaign` notification —
 * same title/body so this is a no-op swap for anyone already on it. */
export const onApplicationCreated = onDocumentCreated(
  "applications/{applicationId}",
  async (event) => {
    const application = event.data?.data();
    if (!application || application.status !== "pending") return;

    await createNotificationIfNew({
      userId: application.brandId,
      type: "newApplication",
      title: "New application",
      body: `${application.creatorName} applied to ${application.campaignTitle}`,
      referenceType: "campaign",
      referenceId: application.campaignId,
    });
  }
);

/** Mirrors the three status-transition notifications previously sent from
 * `campaigns_providers.dart` (withdraw) and `brand_campaign_detail_screen.dart`
 * (accept/reject). */
export const onApplicationStatusChanged = onDocumentUpdated(
  "applications/{applicationId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!after || !before || before.status === after.status) return;

    switch (after.status) {
      case "withdrawn":
        await createNotificationIfNew({
          userId: after.brandId,
          type: "applicationWithdrawn",
          title: "Application withdrawn",
          body: `${after.creatorName} withdrew their application to ${after.campaignTitle}`,
          referenceType: "campaign",
          referenceId: after.campaignId,
        });
        return;
      case "accepted":
        await createNotificationIfNew({
          userId: after.creatorId,
          type: "applicationAccepted",
          title: "Application accepted",
          body: `You've been accepted for ${after.campaignTitle}`,
          referenceType: "campaign",
          referenceId: after.campaignId,
        });
        return;
      case "rejected":
        await createNotificationIfNew({
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
  }
);
