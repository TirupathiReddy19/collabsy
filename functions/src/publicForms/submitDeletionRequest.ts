import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";

import { enforceRateLimit } from "./rateLimit";
import { parseDeletionRequest } from "./validation";

/**
 * The website's "Request account deletion" form, for people who can't open
 * the app. Replaces an anonymous Firestore create with a validated,
 * rate-limited call. The doc is identical to the old one; staff still
 * verify each request before anything is deleted.
 */
export const submitDeletionRequest = onCall(async (request) => {
  const input = parseDeletionRequest(request.data);
  await enforceRateLimit(request, {
    bucket: "deletionRequest",
    perCallerLimit: 3,
    globalLimit: 60,
  });

  await getFirestore().collection("accountDeletionRequests").add({
    identifier: input.identifier,
    ...(input.reason ? { reason: input.reason } : {}),
    status: "pending",
    createdAt: Timestamp.now(),
  });

  return { success: true };
});
