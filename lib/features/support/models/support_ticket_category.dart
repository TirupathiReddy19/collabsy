/// Admin-assigned triage tag for a support ticket — never set by the end
/// user, only by the admin/staff side (see `firestore.rules`).
enum SupportTicketCategory {
  billing,
  technical,
  account,
  campaign,
  other;

  static SupportTicketCategory? fromDbValue(String? value) => switch (value) {
    'billing' => SupportTicketCategory.billing,
    'technical' => SupportTicketCategory.technical,
    'account' => SupportTicketCategory.account,
    'campaign' => SupportTicketCategory.campaign,
    'other' => SupportTicketCategory.other,
    _ => null,
  };

  String toDbValue() => name;

  String get label => switch (this) {
    SupportTicketCategory.billing => 'Billing',
    SupportTicketCategory.technical => 'Technical',
    SupportTicketCategory.account => 'Account',
    SupportTicketCategory.campaign => 'Campaign',
    SupportTicketCategory.other => 'Other',
  };
}
