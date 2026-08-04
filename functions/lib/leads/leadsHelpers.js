"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.normalizeInstagramHandle = normalizeInstagramHandle;
exports.matchLeadToCreator = matchLeadToCreator;
const firestore_1 = require("firebase-admin/firestore");
const firebase_functions_1 = require("firebase-functions");
/**
 * Normalizes a pasted Instagram profile URL or bare handle down to a
 * consistent key — lowercase, no protocol/domain, no leading "@", no
 * query string or trailing path. This is the `leads/{handle}` doc id, so
 * dedup is just a doc-existence check; the exact same logic must be
 * mirrored client-side (intern tool) when checking before creating a lead.
 */
function normalizeInstagramHandle(input) {
    let value = input.trim().toLowerCase();
    value = value.replace(/^https?:\/\/(www\.)?instagram\.com\//, "");
    value = value.replace(/^@/, "");
    value = value.split("?")[0].split("/")[0];
    return value;
}
/**
 * Stamps a `leads/{handle}` doc as matched the moment its target's
 * Instagram account actually connects to a real Collabsy Creator — the
 * sole attribution signal for the intern outreach tool (no referral
 * code, no paid attribution SDK). A lead that's already matched (e.g.
 * re-syncing an existing connection) is left alone.
 */
async function matchLeadToCreator(username, userId) {
    const handle = normalizeInstagramHandle(username);
    if (!handle)
        return;
    try {
        const leadRef = (0, firestore_1.getFirestore)().collection("leads").doc(handle);
        const leadDoc = await leadRef.get();
        if (!leadDoc.exists)
            return;
        if (leadDoc.data()?.matchedUid)
            return;
        await leadRef.set({
            status: "signedUp",
            matchedUid: userId,
            signedUpAt: firestore_1.Timestamp.now(),
        }, { merge: true });
    }
    catch (error) {
        firebase_functions_1.logger.error("Failed to match lead to creator", error);
    }
}
