/// How creators are compensated for a campaign.
enum CompensationType {
  cash,
  barter;

  static CompensationType? fromDbValue(String? value) => switch (value) {
    'cash' => CompensationType.cash,
    'barter' => CompensationType.barter,
    _ => null,
  };

  String toDbValue() => name;

  String get label => switch (this) {
    CompensationType.cash => 'Paid',
    CompensationType.barter => 'Barter',
  };
}
