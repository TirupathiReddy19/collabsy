import 'dart:html' as html;

const _webmailBase = 'https://mail.collabsy.online/webmail/';

/// Opens Collabsy's Modoboa-hosted webmail (Roundcube) in a new tab with a
/// compose window pre-filled, so an intern reviews and actually hits send
/// from their own real mailbox — Sent folder, attachments, signature all
/// work normally — rather than a silent background send they can't see.
/// Uses Roundcube's documented compose-URL query params; the intern still
/// needs to be signed into mail.collabsy.online for this to land on the
/// compose screen rather than its login page. Web-only (`dart:html`), safe
/// here since the brand-intern app is exclusively built for
/// `flutter build web -t lib/main_brand_intern.dart`.
void openWebmailCompose({
  required String to,
  required String subject,
  required String body,
}) {
  final uri = Uri.parse(_webmailBase).replace(
    queryParameters: {
      '_task': 'mail',
      '_action': 'compose',
      '_to': to,
      '_subject': subject,
      '_body': body,
    },
  );
  html.window.open(uri.toString(), '_blank');
}
