import '../../shared/utils/instagram_handle.dart';

/// A profile pushed from the Collabsy Outreach Helper browser extension
/// (`tools/intern-extension`). Kept free of `dart:html` so it can be unit
/// tested — the browser wiring lives in `extension_bridge.dart`.
typedef ExtensionProfile = ({String handle, String url, String bio});

const _maxBioLength = 4000;
final _validHandle = RegExp(r'^[a-z0-9._]{1,30}$');

/// Validates a `window.postMessage` payload from the extension and returns
/// the profile it carries, or null for anything else — including this app's
/// own handshake messages and anything malformed. The URL is rebuilt from
/// the handle rather than trusted from the message.
ExtensionProfile? parseExtensionProfile(Object? message) {
  if (message is! Map) return null;
  if (message['source'] != 'collabsy-extension' ||
      message['type'] != 'profile') {
    return null;
  }

  final payload = message['payload'];
  if (payload is! Map) return null;

  final handle = normalizeInstagramHandle('${payload['handle'] ?? ''}');
  if (!_validHandle.hasMatch(handle)) return null;

  var bio = payload['bio'] is String ? payload['bio'] as String : '';
  if (bio.length > _maxBioLength) bio = bio.substring(0, _maxBioLength);

  return (handle: handle, url: 'https://www.instagram.com/$handle/', bio: bio);
}
