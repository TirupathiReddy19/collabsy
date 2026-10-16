"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.submitCampaignRequest = void 0;
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const rateLimit_1 = require("./rateLimit");
const validation_1 = require("./validation");
/**
 * The Brands page's "run it for us" form. Replaces the website writing to
 * `campaignRequests` directly (an anonymous Firestore create), so the input
 * is validated here and one visitor, and the form as a whole, can only send
 * so many per hour. The doc written is exactly what the old rule allowed, so
 * the admin portal reads it unchanged.
 */
exports.submitCampaignRequest = (0, https_1.onCall)(async (request) => {
    const input = (0, validation_1.parseCampaignRequest)(request.data);
    await (0, rateLimit_1.enforceRateLimit)(request, {
        bucket: "campaignRequest",
        perCallerLimit: 5,
        globalLimit: 100,
    });
    await (0, firestore_1.getFirestore)().collection("campaignRequests").add({
        companyName: input.companyName,
        contactName: input.contactName,
        workEmail: input.workEmail,
        ...(input.phone ? { phone: input.phone } : {}),
        budgetRange: input.budgetRange,
        campaignBrief: input.campaignBrief,
        status: "new",
        createdAt: firestore_1.Timestamp.now(),
    });
    return { success: true };
});
