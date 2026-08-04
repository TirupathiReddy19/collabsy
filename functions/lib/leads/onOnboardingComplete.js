"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onOnboardingComplete = void 0;
const firestore_1 = require("firebase-admin/firestore");
const firestore_2 = require("firebase-functions/v2/firestore");
const firebase_functions_1 = require("firebase-functions");
const brandLeadsHelpers_1 = require("../brandLeads/brandLeadsHelpers");
async function stampOnboardingComplete(collection, uid) {
    const firestore = (0, firestore_1.getFirestore)();
    const matches = await firestore
        .collection(collection)
        .where("matchedUid", "==", uid)
        .get();
    if (matches.empty)
        return;
    const batch = firestore.batch();
    for (const doc of matches.docs) {
        batch.set(doc.ref, {
            status: "onboardingComplete",
            onboardingCompleteAt: firestore_1.Timestamp.now(),
        }, { merge: true });
    }
    await batch.commit();
}
/**
 * Final stage of both outreach funnels (linkGenerated -> clicked ->
 * signedUp -> onboardingComplete). `matchLeadToCreator` (called from
 * `saveProfile` at Instagram-connect time) already stamped `matchedUid` on
 * any `leads` doc this user matched — once their
 * `users/{uid}.onboardingCompleted` flips to true, stamp that same lead as
 * fully onboarded.
 *
 * For `brandLeads`, the equivalent match happens on a `brandProfiles`
 * write (`onBrandProfileWritten`), a separate trigger from this one — since
 * the two can fire in either order relative to each other, this also
 * re-derives the match here from the brand's current `linkedinUrl` before
 * sweeping, so attribution is correct regardless of which trigger's write
 * lands first.
 */
exports.onOnboardingComplete = (0, firestore_2.onDocumentUpdated)("users/{uid}", async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!before || !after)
        return;
    if (before.onboardingCompleted === true)
        return;
    if (after.onboardingCompleted !== true)
        return;
    const uid = event.params.uid;
    const firestore = (0, firestore_1.getFirestore)();
    try {
        await stampOnboardingComplete("leads", uid);
    }
    catch (error) {
        firebase_functions_1.logger.error("Failed to stamp lead onboardingComplete", error);
    }
    try {
        const brandProfileDoc = await firestore
            .collection("brandProfiles")
            .doc(uid)
            .get();
        const linkedinUrl = brandProfileDoc.data()?.linkedinUrl;
        if (linkedinUrl) {
            await (0, brandLeadsHelpers_1.matchBrandLeadToBrand)(linkedinUrl, uid);
        }
        await stampOnboardingComplete("brandLeads", uid);
    }
    catch (error) {
        firebase_functions_1.logger.error("Failed to stamp brand lead onboardingComplete", error);
    }
});
