import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";

/**
 * Normalizes a pasted LinkedIn profile URL down to a consistent key —
 * lowercase, no protocol/domain, no query string or trailing slash, and no
 * internal slashes either (a Firestore document id is a single path
 * segment — `collection("brandLeads").doc("in/johndoe")` is parsed as a
 * multi-segment document *path*, not a doc id containing a literal slash,
 * and throws). This is the `brandLeads/{slug}` doc id, so dedup is just a
 * doc-existence check. Mirrors `leads/leadsHelpers.ts`'s
 * `normalizeInstagramHandle`, except a LinkedIn profile's meaningful path
 * is `in/{slug}` — not just the first segment — so the full path (minus
 * query string and trailing slash) is kept, joined with `_` instead of `/`.
 * Must be mirrored client-side (`lib/shared/utils/linkedin_url.dart`) when
 * checking before creating a lead.
 */
export function normalizeLinkedInUrl(input: string): string {
  let value = input.trim().toLowerCase();
  value = value.replace(/^https?:\/\/(www\.)?linkedin\.com\//, "");
  value = value.split("?")[0];
  value = value.replace(/\/+$/, "");
  value = value.replace(/^\/+/, "");
  value = value.replace(/\//g, "_");
  return value;
}

/**
 * Stamps a `brandLeads/{slug}` doc as matched the moment its target's
 * LinkedIn profile URL shows up in a real Collabsy Brand's onboarding
 * profile — the sole attribution signal for the brand outreach tool (no
 * referral code, no paid attribution SDK), mirroring `matchLeadToCreator`.
 * A lead that's already matched is left alone.
 */
export async function matchBrandLeadToBrand(
  linkedinUrl: string,
  userId: string
): Promise<void> {
  const slug = normalizeLinkedInUrl(linkedinUrl);
  if (!slug) return;

  try {
    const leadRef = getFirestore().collection("brandLeads").doc(slug);
    const leadDoc = await leadRef.get();
    if (!leadDoc.exists) return;
    if (leadDoc.data()?.matchedUid) return;

    await leadRef.set(
      {
        status: "signedUp",
        matchedUid: userId,
        signedUpAt: Timestamp.now(),
      },
      { merge: true }
    );
  } catch (error) {
    logger.error("Failed to match brand lead to brand", error);
  }
}
