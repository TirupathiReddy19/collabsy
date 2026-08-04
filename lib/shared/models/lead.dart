/// One `leads` document — a prospective influencer an intern has started
/// cold-outreach to. Doc id is the normalized Instagram handle (see
/// `normalizeInstagramHandle`), so a second intern pasting the same
/// profile hits an existing doc instead of creating a duplicate. Every
/// field after `status` is written only by Cloud Functions (`redirectLead`,
/// `saveProfile`'s lead-matching hook, `onOnboardingComplete`) — the intern
/// client only ever creates the initial `linkGenerated` doc.
typedef Lead = ({
  String handle,
  String instagramUrl,
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
