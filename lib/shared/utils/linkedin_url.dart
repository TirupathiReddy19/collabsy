/// Normalizes a pasted LinkedIn profile URL down to a consistent key —
/// lowercase, no protocol/domain, no query string or trailing slash, and
/// no internal slashes either (a Firestore document id is a single path
/// segment — `collection('brandLeads').doc('in/johndoe')` is parsed as a
/// 3-segment, even-odd-invalid document *path*, not a doc id containing a
/// literal slash, and throws). Mirrors
/// `functions/src/brandLeads/brandLeadsHelpers.ts`'s `normalizeLinkedInUrl`
/// exactly — this is the `brandLeads/{slug}` doc id, so both sides must
/// agree. Unlike an Instagram handle, a LinkedIn profile's meaningful path
/// is `in/{slug}`, not just the first path segment, so the full path (minus
/// query string and trailing slash) is kept, joined with `_` instead of `/`.
String normalizeLinkedInUrl(String input) {
  var value = input.trim().toLowerCase();
  value = value.replaceFirst(RegExp(r'^https?://(www\.)?linkedin\.com/'), '');
  value = value.split('?').first;
  value = value.replaceFirst(RegExp(r'/+$'), '');
  value = value.replaceFirst(RegExp(r'^/+'), '');
  value = value.replaceAll('/', '_');
  return value;
}
