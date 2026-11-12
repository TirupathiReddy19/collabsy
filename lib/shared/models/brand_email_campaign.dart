/// One `brandEmailCampaigns` doc — a named, reusable subject/body template
/// an intern saves so they can pick it again later instead of retyping the
/// same outreach copy every time they run a bulk send (see
/// `BrandInternCampaignsRepository`). Strictly per-intern: `internId` is
/// set once at creation and never changes, and `firestore.rules` only ever
/// lets its own owner (or admin) read or write a given campaign.
typedef BrandEmailCampaign = ({
  String id,
  String internId,
  String name,
  String subject,
  String body,
  DateTime? createdAt,
  DateTime? updatedAt,
});
