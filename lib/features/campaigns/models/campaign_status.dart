/// Lifecycle of a brand's campaign. Every new campaign starts at
/// [underReview] — only an admin approving it (-> [active]) or rejecting it
/// (-> [rejected]) can move it out of that state; the owning brand cannot
/// self-approve (enforced in `firestore.rules`, not just the UI).
enum CampaignStatus {
  draft,
  underReview,
  active,
  paused,
  rejected,
  closed;

  static CampaignStatus fromDbValue(String? value) => switch (value) {
    'underReview' => CampaignStatus.underReview,
    'active' => CampaignStatus.active,
    'paused' => CampaignStatus.paused,
    'rejected' => CampaignStatus.rejected,
    'closed' => CampaignStatus.closed,
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
  };
}
