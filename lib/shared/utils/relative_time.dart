/// "5m ago" / "2h ago" / "3d ago", falling back to a plain date once it's
/// old enough that a relative label stops being useful. Mirrors the
/// pattern `Campaign.postedAgoLabel` already used for posted-time display,
/// pulled out here so other "last synced/updated" spots can share it.
String relativeTimeLabel(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
