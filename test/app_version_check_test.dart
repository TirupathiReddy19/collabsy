import 'package:collabsy/app/update_gate/app_version_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const androidConfig = {
    'minBuildAndroid': 31,
    'minBuildIos': 31,
    'androidStoreUrl': 'https://play.google.com/store/apps/details?id=online.collabsy.app',
    'iosStoreUrl': 'https://apps.apple.com/in/app/collabsy/id6808197823',
    'message': 'Update to keep using Collabsy.',
  };

  test('a build at or above the minimum is allowed through', () {
    expect(
      evaluateAppVersion(currentBuild: 31, platform: TargetPlatform.android, configData: androidConfig),
      isA<AppVersionOk>(),
    );
    expect(
      evaluateAppVersion(currentBuild: 35, platform: TargetPlatform.android, configData: androidConfig),
      isA<AppVersionOk>(),
    );
  });

  test('a build below the minimum is blocked, with the right store link and message', () {
    final status = evaluateAppVersion(currentBuild: 30, platform: TargetPlatform.android, configData: androidConfig);
    expect(status, isA<AppVersionBlocked>());
    final blocked = status as AppVersionBlocked;
    expect(blocked.storeUrl, androidConfig['androidStoreUrl']);
    expect(blocked.message, 'Update to keep using Collabsy.');
  });

  test('iOS uses its own minimum and store link, independently of Android', () {
    final belowIos = {...androidConfig, 'minBuildIos': 40};
    final status = evaluateAppVersion(currentBuild: 35, platform: TargetPlatform.iOS, configData: belowIos);
    expect(status, isA<AppVersionBlocked>());
    expect((status as AppVersionBlocked).storeUrl, androidConfig['iosStoreUrl']);

    // Android's own, lower minimum still passes with the same config.
    expect(
      evaluateAppVersion(currentBuild: 35, platform: TargetPlatform.android, configData: belowIos),
      isA<AppVersionOk>(),
    );
  });

  test('falls back to the default message when none is set', () {
    final noMessage = {...androidConfig}..remove('message');
    final status = evaluateAppVersion(currentBuild: 30, platform: TargetPlatform.android, configData: noMessage);
    expect((status as AppVersionBlocked).message, defaultUpdateMessage);
  });

  group('fails open — never blocks on something unrecognized', () {
    test('no config doc at all', () {
      expect(
        evaluateAppVersion(currentBuild: 1, platform: TargetPlatform.android, configData: null),
        isA<AppVersionOk>(),
      );
    });

    test('an unsupported platform (web/desktop build of the main app)', () {
      expect(
        evaluateAppVersion(currentBuild: 1, platform: TargetPlatform.windows, configData: androidConfig),
        isA<AppVersionOk>(),
      );
    });

    test('minBuild field missing or the wrong type', () {
      final missing = {...androidConfig}..remove('minBuildAndroid');
      expect(
        evaluateAppVersion(currentBuild: 1, platform: TargetPlatform.android, configData: missing),
        isA<AppVersionOk>(),
      );
      final wrongType = {...androidConfig, 'minBuildAndroid': '31'};
      expect(
        evaluateAppVersion(currentBuild: 1, platform: TargetPlatform.android, configData: wrongType),
        isA<AppVersionOk>(),
      );
    });

    test('a minimum is set but the store link is missing or blank', () {
      final noLink = {...androidConfig}..remove('androidStoreUrl');
      expect(
        evaluateAppVersion(currentBuild: 1, platform: TargetPlatform.android, configData: noLink),
        isA<AppVersionOk>(),
      );
      final blankLink = {...androidConfig, 'androidStoreUrl': ''};
      expect(
        evaluateAppVersion(currentBuild: 1, platform: TargetPlatform.android, configData: blankLink),
        isA<AppVersionOk>(),
      );
    });
  });
}
