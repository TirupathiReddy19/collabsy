/// One `brandLeads` document — a prospective brand contact an intern has
/// started cold-outreach to. Doc id is the normalized LinkedIn profile URL
/// (see `normalizeLinkedInUrl`), so a second intern pasting the same profile
/// hits an existing doc instead of creating a duplicate. Every field after
/// `status` is written only by Cloud Functions (`redirectBrandLead`,
/// `onBrandProfileWritten`, `onOnboardingComplete`) — the intern client only
/// ever creates the initial `linkGenerated` doc. Mirrors `lead.dart` exactly,
/// swapping the Instagram handle/URL for a LinkedIn profile URL.
typedef BrandLead = ({
  String handle,
  String linkedinUrl,
  String internId,
  String internEmail,
  String message,
  String status,
  DateTime? createdAt,
  DateTime? clickedAt,
  int clickCount,
  String? matchedUid,
  DateTime? signedUpAt,
  DateTime? onboardingCompleteAt,
});
