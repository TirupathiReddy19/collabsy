/// Local-device `YYYY-MM-DD` — used to bucket per-day records (e.g.
/// `internShiftStats/{internId}_{dateKey}`) by the device's own wall-clock
/// day rather than UTC.
String dateKey(DateTime day) =>
    '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
