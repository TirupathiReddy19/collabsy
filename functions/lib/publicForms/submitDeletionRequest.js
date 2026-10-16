"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.submitDeletionRequest = void 0;
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const rateLimit_1 = require("./rateLimit");
const validation_1 = require("./validation");
/**
 * The website's "Request account deletion" form, for people who can't open
 * the app. Replaces an anonymous Firestore create with a validated,
 * rate-limited call. The doc is identical to the old one; staff still
 * verify each request before anything is deleted.
 */
exports.submitDeletionRequest = (0, https_1.onCall)(async (request) => {
    const input = (0, validation_1.parseDeletionRequest)(request.data);
    await (0, rateLimit_1.enforceRateLimit)(request, {
        bucket: "deletionRequest",
        perCallerLimit: 3,
        globalLimit: 60,
    });
    await (0, firestore_1.getFirestore)().collection("accountDeletionRequests").add({
        identifier: input.identifier,
        ...(input.reason ? { reason: input.reason } : {}),
        status: "pending",
        createdAt: firestore_1.Timestamp.now(),
    });
    return { success: true };
});
