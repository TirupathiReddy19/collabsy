/// What a creator delivers for a campaign.
enum DeliverableType {
  collabReel,
  nonCollab,
  both;

  static DeliverableType? fromDbValue(String? value) => switch (value) {
    'collabReel' => DeliverableType.collabReel,
    'nonCollab' => DeliverableType.nonCollab,
    'both' => DeliverableType.both,
    _ => null,
  };

  String toDbValue() => name;

  String get label => switch (this) {
    DeliverableType.collabReel => 'Collab Reel',
    DeliverableType.nonCollab => 'Non-Collab Post',
    DeliverableType.both => 'Both',
  };
}
