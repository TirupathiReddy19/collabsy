/// Whether a support thread still needs attention.
enum SupportChatStatus {
  open,
  resolved;

  static SupportChatStatus fromDbValue(String? value) =>
      value == 'resolved' ? SupportChatStatus.resolved : SupportChatStatus.open;

  String toDbValue() => name;

  String get label => switch (this) {
    SupportChatStatus.open => 'Open',
    SupportChatStatus.resolved => 'Resolved',
  };
}
