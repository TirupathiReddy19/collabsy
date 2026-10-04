import 'package:collabsy/shared/utils/email_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('extractEmails', () {
    test('finds a plain email in bio text', () {
      expect(
        extractEmails('Fashion creator ✨ Delhi\n📩 priya.sharma@gmail.com'),
        ['priya.sharma@gmail.com'],
      );
    });

    test('handles bracketed obfuscation', () {
      expect(extractEmails('collabs: priya [at] gmail [dot] com'), [
        'priya@gmail.com',
      ]);
      expect(extractEmails('mail: hello (at) brand (dot) in'), [
        'hello@brand.in',
      ]);
    });

    test('handles spelled-out common providers', () {
      expect(extractEmails('reach me: priya.s at gmail dot com'), [
        'priya.s@gmail.com',
      ]);
    });

    test('handles full-width at-sign and zero-width characters', () {
      expect(extractEmails('priya＠gmail.com'), ['priya@gmail.com']);
      expect(extractEmails('pri​ya@gmail.com'), ['priya@gmail.com']);
    });

    test('lowercases and de-duplicates, keeping order', () {
      expect(extractEmails('A@Gmail.com | b@brand.in | a@gmail.com'), [
        'a@gmail.com',
        'b@brand.in',
      ]);
    });

    test('strips trailing punctuation from the match', () {
      expect(extractEmails('email: priya@gmail.com.'), ['priya@gmail.com']);
    });

    test('does not invent emails from ordinary text', () {
      expect(extractEmails('meet me at the cafe, dot com bubble'), isEmpty);
      expect(extractEmails('DM @priya_official for collabs'), isEmpty);
      expect(extractEmails(''), isEmpty);
    });
  });

  group('pickBestEmail', () {
    test('prefers Gmail over earlier non-Gmail emails', () {
      expect(
        pickBestEmail(['biz@brand.in', 'priya@gmail.com']),
        'priya@gmail.com',
      );
    });

    test('falls back to the first email when none is Gmail', () {
      expect(pickBestEmail(['a@brand.in', 'b@yahoo.com']), 'a@brand.in');
    });

    test('returns null when there are no emails', () {
      expect(pickBestEmail(const []), isNull);
    });
  });

  group('looksLikeEmail', () {
    test('accepts normal addresses and rejects junk', () {
      expect(looksLikeEmail(' Priya@Gmail.com '), isTrue);
      expect(looksLikeEmail('priya@gmail'), isFalse);
      expect(looksLikeEmail('not an email'), isFalse);
    });
  });
}
