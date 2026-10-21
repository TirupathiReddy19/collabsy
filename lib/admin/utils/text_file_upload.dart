import 'dart:async';
import 'dart:html' as html;

/// Opens the browser's native file picker and resolves with the picked
/// file's text content, or `null` if the user cancelled. Web-only
/// (`dart:html`) — mirrors `csv_download.dart`'s convention of keeping
/// browser-only APIs in their own small util, safe here because the admin
/// app is exclusively built for `flutter build web -t lib/main_admin.dart`.
Future<String?> pickTextFile({String accept = '.json'}) {
  final input = html.FileUploadInputElement()..accept = accept;
  input.click();

  final completer = Completer<String?>();
  input.onChange.first.then((_) {
    final files = input.files;
    final file = (files == null || files.isEmpty) ? null : files[0];
    if (file == null) {
      completer.complete(null);
      return;
    }
    final reader = html.FileReader();
    reader.onLoadEnd.first.then((_) {
      completer.complete(reader.result as String?);
    });
    reader.readAsText(file);
  });
  return completer.future;
}
