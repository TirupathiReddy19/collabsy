/// One `brandEmailSends` doc — a record of one send action, written by
/// either `sendBrandProspectMassEmail` ([type] `'bulk'`, one recipient
/// count across however many people were in that send) or
/// `sendBrandProspectEmail` ([type] `'direct'`, always `recipientCount: 1`)
/// — never one doc per recipient. Answers "which campaign did I send, to
/// how many people, and when" for the intern's own Dashboard tab, admin's
/// Brand Outreach Reports, and the Marketing Tracker's daily targets
/// (250 campaign emails / 250 direct-contact emails per intern per day).
/// `campaignId` is `null` for a direct send or a one-off "Custom message"
/// bulk send that wasn't tied to a saved `BrandEmailCampaign`.
typedef BrandEmailSend = ({
  String id,
  String internId,
  String internEmail,
  String type,
  String? campaignId,
  String campaignName,
  String subject,
  int recipientCount,
  DateTime? sentAt,
});
