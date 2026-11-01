/// One `brandProspects` document — a scraped brand contact from the bulk
/// research import, distinct from `BrandLead` (a specific LinkedIn profile
/// an intern personally found and generated a tracking link for). Doc id is
/// a slug derived from the brand's website (see the one-time import
/// script), so re-importing the same source file is idempotent.
///
/// Every prospect starts `status: 'unassigned'` with no `assignedTo`. Admin
/// pushes a whole category to one intern at once (see
/// `AdminBrandProspectsRepository.assignCategoryToIntern`), which is the
/// only thing that sets `assignedTo`/`assignedToEmail`/`assignedAt` and
/// flips `status` to `'assigned'`. The assigned intern can self-report
/// `contacted` (one-way) via a plain Firestore write, or send a real
/// outreach email through `sendBrandProspectEmail` (a Cloud Function, since
/// it both owns the SMTP send and stamps `emailSentAt`/`emailSentCount` —
/// fields no client write is allowed to touch directly) which also flips
/// `contacted` as a side effect. Still a reference list, not a
/// tracked-link funnel like `BrandLead` — no click tracking either way.
typedef BrandProspect = ({
  String id,
  String brandName,
  String? website,
  String? category,
  String? rawCategory,
  String? location,
  String? city,
  String? teamSize,
  String? igFollowers,
  String? monthlyVisits,
  String? instagramUrl,
  String? linkedinUrl,
  List<String> emails,
  String status,
  String? assignedTo,
  String? assignedToEmail,
  DateTime? assignedAt,
  bool contacted,
  DateTime? contactedAt,
  DateTime? emailSentAt,
  int emailSentCount,
});
