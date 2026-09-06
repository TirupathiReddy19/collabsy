/// Lightweight, dependency-free time formatting for the chat list and
/// conversation screens — mirrors how Instagram DMs show timestamps
/// (short relative labels in the list, "Today, 2:45 PM"-style separators
/// between message clusters) without pulling in `intl` for just this.
library;

const _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _time12h(DateTime dt) {
  final hour24 = dt.hour;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = hour24 < 12 ? 'AM' : 'PM';
  return '$hour12:$minute $period';
}

/// A compact label for the chat list row, e.g. "now", "5m", "3h", "2d",
/// "Tue", or "12 Sep" for anything older than a week.
String chatListTimestamp(DateTime dt, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(dt);

  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  if (diff.inDays < 14) return _weekdayNames[dt.weekday - 1].substring(0, 3);
  return '${dt.day} ${_monthNames[dt.month - 1]}';
}

/// A centered separator label shown between message clusters in the
/// conversation screen, e.g. "Today, 2:45 PM", "Yesterday, 10:12 AM",
/// "Tuesday, 3:15 PM", or "12 Sep, 3:15 PM" for anything older than a week.
String chatSeparatorLabel(DateTime dt, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dayOnly = DateTime(dt.year, dt.month, dt.day);

  if (_isSameDay(dayOnly, today)) return 'Today, ${_time12h(dt)}';
  if (_isSameDay(dayOnly, yesterday)) return 'Yesterday, ${_time12h(dt)}';
  if (today.difference(dayOnly).inDays < 7) {
    return '${_weekdayNames[dt.weekday - 1]}, ${_time12h(dt)}';
  }
  return '${dt.day} ${_monthNames[dt.month - 1]}, ${_time12h(dt)}';
}
