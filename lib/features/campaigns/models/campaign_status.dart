/// Lifecycle of a brand's campaign. Every new campaign starts at
/// [underReview] — only an admin approving it (-> [active]) or rejecting it
/// (-> [rejected]) can move it out of that state; the owning brand cannot
/// self-approve (enforced in `firestore.rules`, not just the UI).
///
/// [expired] is set automatically by the `expireCampaigns` scheduled Cloud
/// Function once a campaign's `endDate` passes — distinct from [closed],
/// which is the brand ending a campaign early on their own.
enum CampaignStatus {
  draft,
  underReview,
  active,
  paused,
  rejected,
  closed,
  expired;

  static CampaignStatus fromDbValue(String? value) => switch (value) {
    'underReview' => CampaignStatus.underReview,
    'active' => CampaignStatus.active,
    'paused' => CampaignStatus.paused,
    'rejected' => CampaignStatus.rejected,
    'closed' => CampaignStatus.closed,
    'expired' => CampaignStatus.expired,
    _ => CampaignStatus.draft,
  };

  String toDbValue() => name;

  String get label => switch (this) {
    CampaignStatus.draft => 'Draft',
    CampaignStatus.underReview => 'Under review',
    CampaignStatus.active => 'Active',
    CampaignStatus.paused => 'Paused',
    CampaignStatus.rejected => 'Rejected',
    CampaignStatus.closed => 'Closed',
    CampaignStatus.expired => 'Expired',
  };
}
