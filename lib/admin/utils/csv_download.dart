import 'dart:convert';
import 'dart:html' as html;

/// Triggers a browser download of [csvContent] as [filename]. Web-only
/// (`dart:html`) — safe here because the admin app is exclusively built
/// for `flutter build web -t lib/main_admin.dart` and this file is never
/// reachable from the mobile app's entry point.
void downloadCsv(String filename, String csvContent) {
  final bytes = utf8.encode(csvContent);
  final blob = html.Blob([bytes], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
