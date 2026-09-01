/// Collected once, either during signup onboarding or (for accounts that
/// existed before this field did) via a one-time gate the router sends
/// them through — see `CreatorAdditionalDetailsScreen`. Shown on the
/// creator's own profile, the Brand-facing public profile, and the admin
/// Creator detail screen.
enum CreatorGender {
  male,
  female;

  String toDbValue() => name;

  String get label => switch (this) {
    CreatorGender.male => 'Male',
    CreatorGender.female => 'Female',
  };
}
