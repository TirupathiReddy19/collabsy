"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.stampBrandVerificationRequestedAt = exports.stampCreatorVerificationRequestedAt = void 0;
const firestore_1 = require("firebase-admin/firestore");
const firestore_2 = require("firebase-functions/v2/firestore");
/** Stamps `verificationRequestedAt` the first moment a profile is sitting in
 * `pending` review — the clock `remindPendingVerifications` measures its
 * 15-minute SLA against. Fires on both create (a brand-new profile already
 * defaults to `pending`) and update (an admin rejects, the user edits
 * something and it reverts to `pending` again — same re-review clock either
 * way), but only ever writes the field once: if it's already set, a later
 * write (a bio edit while still pending, the eventual approve/reject) must
 * never reset it, or the reminder's 15-minute window would restart forever
 * and never fire. */
async function stampIfNewlyPending(collection, userId) {
    const ref = (0, firestore_1.getFirestore)().collection(collection).doc(userId);
    const doc = await ref.get();
    const data = doc.data();
    if (!data)
        return;
    // Mirrors the Flutter app's @Default(VerificationStatus.pending): a
    // document with no verificationStatus field at all is "pending" to the
    // app's own deserialization just as much as one that explicitly says so.
    const isPending = data.verificationStatus === "pending" || data.verificationStatus === undefined;
    if (!isPending)
        return;
    if (data.verificationRequestedAt)
        return;
    await ref.set({ verificationRequestedAt: firestore_1.Timestamp.now() }, { merge: true });
}
exports.stampCreatorVerificationRequestedAt = (0, firestore_2.onDocumentWritten)("creatorProfiles/{userId}", async (event) => {
    if (!event.data?.after.exists)
        return;
    await stampIfNewlyPending("creatorProfiles", event.params.userId);
});
exports.stampBrandVerificationRequestedAt = (0, firestore_2.onDocumentWritten)("brandProfiles/{userId}", async (event) => {
    if (!event.data?.after.exists)
        return;
    await stampIfNewlyPending("brandProfiles", event.params.userId);
});
