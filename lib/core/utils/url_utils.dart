final _schemePattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://');

/// Normalizes a user-entered URL before launching it. Many users type a
/// bare domain like "collabsy.online" with no scheme — `Uri.tryParse`
/// happily accepts that as a *relative path*, not a host, so `launchUrl`
/// would open it relative to the current page (e.g.
/// `http://localhost:1234/collabsy.online`) instead of as an external site.
Uri? normalizedExternalUri(String? input) {
  if (input == null) return null;
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  final withScheme = _schemePattern.hasMatch(trimmed)
      ? trimmed
      : 'https://$trimmed';
  return Uri.tryParse(withScheme);
}
