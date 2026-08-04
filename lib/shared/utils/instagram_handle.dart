/// Normalizes a pasted Instagram profile URL or bare handle down to a
/// consistent key — lowercase, no protocol/domain, no leading "@", no
/// query string or trailing path. Mirrors
/// `functions/src/leads/leadsHelpers.ts`'s `normalizeInstagramHandle`
/// exactly — this is the `leads/{handle}` doc id, so both sides must agree.
String normalizeInstagramHandle(String input) {
  var value = input.trim().toLowerCase();
  value = value.replaceFirst(RegExp(r'^https?://(www\.)?instagram\.com/'), '');
  value = value.replaceFirst(RegExp(r'^@'), '');
  value = value.split('?').first.split('/').first;
  return value;
}
