/// One `brandEmailCampaigns` doc — a named, reusable subject/body template
/// an intern saves so they can pick it again later instead of retyping the
/// same outreach copy every time they run a bulk send (see
/// `BrandInternCampaignsRepository`). Strictly per-intern: `internId` is
/// set once at creation and never changes, and `firestore.rules` only ever
/// lets its own owner (or admin) write a given campaign.
///
/// [shared] is the one exception to per-intern ownership: a company-wide
/// template every intern's dropdown shows (read-only to them — only an
/// admin can create, edit, or delete one, per `firestore.rules`; there's no
/// client write path for it at all). `internId` is still set on a shared
/// template (whichever admin account created it), it just stops meaning
/// "who can use this."
typedef BrandEmailCampaign = ({
  String id,
  String internId,
  String name,
  String subject,
  String body,
  bool shared,
  DateTime? createdAt,
  DateTime? updatedAt,
});
