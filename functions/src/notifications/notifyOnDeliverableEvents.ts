import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { getFirestore } from "firebase-admin/firestore";

import { createNotificationIfNew } from "./createNotificationIfNew";

/** Mirrors the submit/approve notifications previously sent from
 * `creator_campaign_detail_screen.dart` and `brand_campaign_detail_screen.dart`.
 * Deliverables don't carry the campaign title themselves, so this reads it
 * off the campaign doc — same lookup the client screens already did via
 * their own campaign provider. */
export const onDeliverableStatusChanged = onDocumentUpdated(
  "deliverables/{deliverableId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!after || !before || before.status === after.status) return;
    if (after.status !== "submitted" && after.status !== "approved") return;

    const campaignDoc = await getFirestore()
      .collection("campaigns")
      .doc(after.campaignId)
      .get();
    const campaignTitle = (campaignDoc.data()?.title as string) ?? "your campaign";

    if (after.status === "submitted") {
      await createNotificationIfNew({
        userId: after.brandId,
        type: "deliverableSubmitted",
        title: "Deliverable submitted",
        body: `${after.creatorName} submitted their deliverable for ${campaignTitle}`,
        referenceType: "campaign",
        referenceId: after.campaignId,
      });
      return;
    }

    await createNotificationIfNew({
      userId: after.creatorId,
      type: "deliverableApproved",
      title: "Deliverable approved",
      body: `Your deliverable for ${campaignTitle} was approved!`,
      referenceType: "campaign",
      referenceId: after.campaignId,
    });
  }
);
