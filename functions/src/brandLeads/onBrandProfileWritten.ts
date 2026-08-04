import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions";

import { matchBrandLeadToBrand } from "./brandLeadsHelpers";

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
export const onBrandProfileWritten = onDocumentWritten(
  "brandProfiles/{userId}",
  async (event) => {
    const after = event.data?.after?.data();
    if (!after) return;

    const linkedinUrl = after.linkedinUrl as string | undefined;
    if (!linkedinUrl) return;

    try {
      await matchBrandLeadToBrand(linkedinUrl, event.params.userId);
    } catch (error) {
      logger.error("Failed to process brand profile write", error);
    }
  }
);
