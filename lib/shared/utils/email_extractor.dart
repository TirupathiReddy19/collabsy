/// Pulls contact emails out of pasted Instagram bio text. Pure string work —
/// no network, no AI. Handles the usual bio obfuscations ("name [at] gmail
/// [dot] com", full-width "＠", zero-width characters) but deliberately
/// nothing fuzzier, since a wrong guess here becomes a wrong outreach email.
final _zeroWidth = RegExp('[​‌‍⁠﻿]');
final _bracketAt = RegExp(r'\s*[\[\(\{]\s*at\s*[\]\)\}]\s*');
final _bracketDot = RegExp(r'\s*[\[\(\{]\s*dot\s*[\]\)\}]\s*');
final _spelledOut = RegExp(
  r'([a-z0-9._%+\-]+)\s+at\s+'
  r'(gmail|yahoo|outlook|hotmail|icloud|proton)\s+dot\s+'
  r'(com|in|co\.in|me)\b',
);
final _emailPattern = RegExp(
  r'[a-z0-9._%+\-]+@[a-z0-9\-]+(?:\.[a-z0-9\-]+)*\.[a-z]{2,}',
);

/// Every distinct email found in [text], lowercased, in order of appearance.
List<String> extractEmails(String text) {
  var value = text
      .replaceAll(_zeroWidth, '')
      .replaceAll('＠', '@')
      .toLowerCase();
  value = value
      .replaceAll(_bracketAt, '@')
      .replaceAll(_bracketDot, '.')
      .replaceAllMapped(_spelledOut, (m) => '${m[1]}@${m[2]}.${m[3]}');

  final seen = <String>{};
  final emails = <String>[];
  for (final match in _emailPattern.allMatches(value)) {
    final email = match.group(0)!.replaceAll(RegExp(r'[._\-]+$'), '');
    if (seen.add(email)) emails.add(email);
  }
  return emails;
}

bool isGmail(String email) {
  final domain = email.split('@').last;
  return domain == 'gmail.com' || domain == 'googlemail.com';
}

/// The email the intern most likely wants: a Gmail address if the bio has
/// one, otherwise the first email found. Null when there are none.
String? pickBestEmail(List<String> emails) {
  if (emails.isEmpty) return null;
  return emails.firstWhere(isGmail, orElse: () => emails.first);
}

/// Loose shape check for an email the intern typed by hand.
bool looksLikeEmail(String value) {
  return RegExp(
    r'^[a-z0-9._%+\-]+@[a-z0-9\-]+(\.[a-z0-9\-]+)*\.[a-z]{2,}$',
  ).hasMatch(value.trim().toLowerCase());
}
