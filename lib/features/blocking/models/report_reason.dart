/// Why a user is reporting another — shown as the reason picker in the
/// report dialog and surfaced as-is on the Admin's Reports queue.
enum ReportReason {
  spam,
  harassment,
  inappropriate,
  fakeProfile,
  other;

  static ReportReason fromDbValue(String? value) => switch (value) {
    'spam' => ReportReason.spam,
    'harassment' => ReportReason.harassment,
    'inappropriate' => ReportReason.inappropriate,
    'fakeProfile' => ReportReason.fakeProfile,
    _ => ReportReason.other,
  };

  String toDbValue() => name;

  String get label => switch (this) {
    ReportReason.spam => 'Spam',
    ReportReason.harassment => 'Harassment or abuse',
    ReportReason.inappropriate => 'Inappropriate content',
    ReportReason.fakeProfile => 'Fake profile',
    ReportReason.other => 'Other',
  };
}
