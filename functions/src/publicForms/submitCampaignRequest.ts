import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";

import { enforceRateLimit } from "./rateLimit";
import { parseCampaignRequest } from "./validation";

/**
 * The Brands page's "run it for us" form. Replaces the website writing to
 * `campaignRequests` directly (an anonymous Firestore create), so the input
 * is validated here and one visitor, and the form as a whole, can only send
 * so many per hour. The doc written is exactly what the old rule allowed, so
 * the admin portal reads it unchanged.
 */
export const submitCampaignRequest = onCall(async (request) => {
  const input = parseCampaignRequest(request.data);
  await enforceRateLimit(request, {
    bucket: "campaignRequest",
    perCallerLimit: 5,
    globalLimit: 100,
  });

  await getFirestore().collection("campaignRequests").add({
    companyName: input.companyName,
    contactName: input.contactName,
    workEmail: input.workEmail,
    ...(input.phone ? { phone: input.phone } : {}),
    budgetRange: input.budgetRange,
    campaignBrief: input.campaignBrief,
    status: "new",
    createdAt: Timestamp.now(),
  });

  return { success: true };
});
