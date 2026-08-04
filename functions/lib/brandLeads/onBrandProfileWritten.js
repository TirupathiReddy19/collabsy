"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onBrandProfileWritten = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const firebase_functions_1 = require("firebase-functions");
const brandLeadsHelpers_1 = require("./brandLeadsHelpers");
/**
 * Brand-side equivalent of `saveProfile` calling `matchLeadToCreator` on
 * Instagram connect. There's no OAuth step for Brands — the "LinkedIn
 * profile" field is just typed in during onboarding (`brand_details_screen
 * .dart`'s Contact step) — so a plain Firestore trigger on the profile
 * write is the right, secure place to attempt a match: the client must
 * never be allowed to write `brandLeads` directly (same reasoning as
 * `leads`), and this fires regardless of which client wrote the field.
 * Runs on every write (not just the first), same as the field being
 * editable later from `brand_account_screen.dart` — `matchBrandLeadToBrand`
 * itself is a no-op once a lead is already matched.
 */
exports.onBrandProfileWritten = (0, firestore_1.onDocumentWritten)("brandProfiles/{userId}", async (event) => {
    const after = event.data?.after?.data();
    if (!after)
        return;
    const linkedinUrl = after.linkedinUrl;
    if (!linkedinUrl)
        return;
    try {
        await (0, brandLeadsHelpers_1.matchBrandLeadToBrand)(linkedinUrl, event.params.userId);
    }
    catch (error) {
        firebase_functions_1.logger.error("Failed to process brand profile write", error);
    }
});
