/// Lifecycle of a creator's application to a campaign.
enum ApplicationStatus {
  pending,
  accepted,
  rejected,
  withdrawn,
  completed;

  static ApplicationStatus fromDbValue(String? value) => switch (value) {
    'accepted' => ApplicationStatus.accepted,
    'rejected' => ApplicationStatus.rejected,
    'withdrawn' => ApplicationStatus.withdrawn,
    'completed' => ApplicationStatus.completed,
    _ => ApplicationStatus.pending,
  };

  String toDbValue() => name;

  String get label => switch (this) {
    ApplicationStatus.pending => 'Pending',
    ApplicationStatus.accepted => 'Accepted',
    ApplicationStatus.rejected => 'Rejected',
    ApplicationStatus.withdrawn => 'Withdrawn',
    ApplicationStatus.completed => 'Completed',
  };
}
