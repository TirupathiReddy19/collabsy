import 'dart:async';
import 'dart:html' as html;

import 'extension_profile.dart';

/// Receives profiles from the Collabsy Outreach Helper extension. Web-only
/// (`dart:html`), same as `csv_download.dart` — safe because the intern
/// tool is exclusively built for `flutter build web -t lib/main_intern.dart`
/// and this file is never reachable from the mobile app's entry point.
///
/// The extension's page script relays a profile in via same-origin
/// `postMessage`. [start] announces this page is ready (so a profile sent
/// while the tool was still loading is replayed) and every profile handled
/// is acknowledged (so it isn't replayed again).
class ExtensionBridge {
  ExtensionBridge(this.onProfile);

  final void Function(ExtensionProfile profile) onProfile;
  StreamSubscription<html.MessageEvent>? _subscription;

  void start() {
    _subscription = html.window.onMessage.listen((event) {
      if (event.origin != html.window.location.origin) return;
      final profile = parseExtensionProfile(event.data);
      if (profile == null) return;
      onProfile(profile);
      _post('received');
    });
    _post('ready');
  }

  void dispose() => _subscription?.cancel();

  void _post(String type) {
    html.window.postMessage({
      'source': 'collabsy-app',
      'type': type,
    }, html.window.location.origin);
  }
}
