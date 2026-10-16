import 'package:collabsy/intern/utils/extension_profile.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _message({
  String source = 'collabsy-extension',
  String type = 'profile',
  Object? payload,
}) => {'source': source, 'type': type, 'payload': payload};

void main() {
  group('parseExtensionProfile', () {
    test('accepts a valid message and rebuilds the URL from the handle', () {
      final profile = parseExtensionProfile(
        _message(
          payload: {
            'handle': 'Priya.Sharma',
            'bio': 'Fashion ✨ priya@gmail.com',
            'url': 'https://evil.example/phish',
          },
        ),
      );

      expect(profile, isNotNull);
      expect(profile!.handle, 'priya.sharma');
      expect(profile.url, 'https://www.instagram.com/priya.sharma/');
      expect(profile.bio, 'Fashion ✨ priya@gmail.com');
    });

    test("ignores the app's own handshake messages", () {
      expect(
        parseExtensionProfile({'source': 'collabsy-app', 'type': 'ready'}),
        isNull,
      );
    });

    test('ignores messages from anything else', () {
      expect(parseExtensionProfile(_message(source: 'someone-else')), isNull);
      expect(parseExtensionProfile(_message(type: 'other')), isNull);
      expect(parseExtensionProfile('just a string'), isNull);
      expect(parseExtensionProfile(null), isNull);
    });

    test('rejects a missing payload or an invalid handle', () {
      expect(parseExtensionProfile(_message()), isNull);
      expect(
        parseExtensionProfile(_message(payload: {'handle': '', 'bio': 'x'})),
        isNull,
      );
      expect(
        parseExtensionProfile(
          _message(payload: {'handle': 'not a handle!', 'bio': 'x'}),
        ),
        isNull,
      );
      expect(
        parseExtensionProfile(
          _message(payload: {'handle': 'a' * 31, 'bio': 'x'}),
        ),
        isNull,
      );
    });

    test('tolerates a missing bio and caps an oversized one', () {
      expect(
        parseExtensionProfile(_message(payload: {'handle': 'priya'}))!.bio,
        '',
      );
      expect(
        parseExtensionProfile(
          _message(payload: {'handle': 'priya', 'bio': 'x' * 9000}),
        )!.bio.length,
        4000,
      );
    });
  });
}
