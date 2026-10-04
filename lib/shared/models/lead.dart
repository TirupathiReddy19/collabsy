/// One `leads` document — a prospective influencer an intern has started
/// cold-outreach to. Doc id is the normalized Instagram handle (see
/// `normalizeInstagramHandle`), so a second intern pasting the same
/// profile hits an existing doc instead of creating a duplicate. Every
/// field after `status` is written only by Cloud Functions (`redirectLead`,
/// `saveProfile`'s lead-matching hook, `onOnboardingComplete`), except
/// `internConfirmedSent(At)` — the one-way false-to-true self-report the
/// intern makes after actually sending the DM in Instagram (see the timed
/// reveal in `intern_home_screen.dart`'s `_SuccessCard`). It's not proof —
/// nothing can verify a DM was actually sent outside Instagram's own
/// systems — but it turns silence into a checkable claim.
///
/// `contactEmail` is the influencer's public email, if the intern spotted
/// one in their bio — pulled out of pasted bio text on the client (see
/// `email_extractor.dart`) and set once at creation. Empty when none.
typedef Lead = ({
  String handle,
  String instagramUrl,
  String internId,
  String internEmail,
  String contactEmail,
  String message,
  String comment,
  String status,
  DateTime? createdAt,
  DateTime? clickedAt,
  int clickCount,
  String? matchedUid,
  DateTime? signedUpAt,
  DateTime? onboardingCompleteAt,
  bool internConfirmedSent,
  DateTime? internConfirmedSentAt,
  DateTime? lastFollowUpSentAt,
  int followUpCount,
});
