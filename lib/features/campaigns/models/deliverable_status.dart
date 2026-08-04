/// Lifecycle of a single accepted creator's deliverable submission for a
/// campaign — distinct from [DeliverableType], which describes what kind of
/// content the campaign asks for (Collab Reel / Non-Collab / Both).
enum DeliverableStatus {
  pending,
  submitted,
  approved;

  static DeliverableStatus fromDbValue(String? value) => switch (value) {
    'submitted' => DeliverableStatus.submitted,
    'approved' => DeliverableStatus.approved,
    _ => DeliverableStatus.pending,
  };

  String toDbValue() => name;

  String get label => switch (this) {
    DeliverableStatus.pending => 'Pending',
    DeliverableStatus.submitted => 'Submitted',
    DeliverableStatus.approved => 'Approved',
  };
}
