/// One `brandEmailSends` doc — a record of one bulk-send action (see
/// `sendBrandProspectMassEmail`, the only writer), not one per recipient.
/// Answers "which campaign did I send, to how many people, and when" for
/// both the intern's own Dashboard tab and admin's Brand Outreach Reports.
/// `campaignId` is `null` for a one-off "Custom message" send that wasn't
/// tied to a saved `BrandEmailCampaign`.
typedef BrandEmailSend = ({
  String id,
  String internId,
  String internEmail,
  String? campaignId,
  String campaignName,
  String subject,
  int recipientCount,
  DateTime? sentAt,
});
