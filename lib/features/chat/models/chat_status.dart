/// Whether a chat thread sits in the "Requests" inbox (unsolicited/
/// pre-relationship contact) or "Messages" (an established conversation).
enum ChatStatus {
  request,
  active;

  static ChatStatus fromDbValue(String? value) => switch (value) {
    'active' => ChatStatus.active,
    _ => ChatStatus.request,
  };

  String toDbValue() => name;
}
