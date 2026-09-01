/// What kind of collaborations a creator is open to — collected alongside
/// [CreatorGender] (see that file's doc comment for where this shows up
/// and how it's backfilled for pre-existing accounts).
enum CollaborationPreference {
  paid,
  barter,
  both;

  String toDbValue() => name;

  String get label => switch (this) {
    CollaborationPreference.paid => 'Paid collaborations',
    CollaborationPreference.barter => 'Barter (gifting/product)',
    CollaborationPreference.both => 'Both paid and barter',
  };

  /// Short form for compact spots like chips/badges on a profile card.
  String get shortLabel => switch (this) {
    CollaborationPreference.paid => 'Paid only',
    CollaborationPreference.barter => 'Barter only',
    CollaborationPreference.both => 'Paid or barter',
  };
}
