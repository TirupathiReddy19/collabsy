import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The result of comparing this install's own build number against the
/// published minimum in `config/appVersion`. A blocked result always
/// carries the fields [UpdateRequiredScreen] needs (the message, and which
/// store to send the user to) — see [evaluateAppVersion].
sealed class AppVersionStatus {
  const AppVersionStatus();
}

class AppVersionOk extends AppVersionStatus {
  const AppVersionOk();
}

class AppVersionBlocked extends AppVersionStatus {
  const AppVersionBlocked({required this.message, required this.storeUrl});
  final String message;
  final String storeUrl;
}

const defaultUpdateMessage =
    'A new version of Collabsy is available. Please update to continue.';

/// The pure decision: given this install's own build number, its platform,
/// and whatever `config/appVersion` currently holds (or `null` if the doc
/// doesn't exist), decide whether to block. No I/O, so it's exercised
/// directly in tests instead of through a live Firestore/PackageInfo call.
///
/// Fails OPEN on anything it doesn't recognize: a missing doc, a missing or
/// wrong-typed field, an unsupported platform, or a missing store link all
/// resolve to [AppVersionOk] rather than blocking the app. A config typo or
/// an unrecognized platform must never be able to lock every user out —
/// only a deliberate, correctly-set minimum build can.
AppVersionStatus evaluateAppVersion({
  required int currentBuild,
  required TargetPlatform platform,
  required Map<String, dynamic>? configData,
}) {
  if (configData == null) return const AppVersionOk();

  final platformKey = switch (platform) {
    TargetPlatform.android => 'minBuildAndroid',
    TargetPlatform.iOS => 'minBuildIos',
    _ => null, // web/desktop builds of the main app don't exist; fail open
  };
  if (platformKey == null) return const AppVersionOk();

  final minBuild = configData[platformKey];
  if (minBuild is! int || currentBuild >= minBuild) {
    return const AppVersionOk();
  }

  final storeUrlField =
      platform == TargetPlatform.android ? 'androidStoreUrl' : 'iosStoreUrl';
  final storeUrl = configData[storeUrlField];
  if (storeUrl is! String || storeUrl.isEmpty) {
    // A minimum is set but the store link isn't — can't send the user
    // anywhere useful, so don't block them on a dead end.
    return const AppVersionOk();
  }

  final message = configData['message'];
  return AppVersionBlocked(
    message: message is String && message.trim().isNotEmpty
        ? message
        : defaultUpdateMessage,
    storeUrl: storeUrl,
  );
}

/// The I/O wrapper [AppBootstrap] actually calls: reads this install's own
/// build number and `config/appVersion` (admin-writable, publicly readable
/// — see firestore.rules — so this works before sign-in too), then applies
/// [evaluateAppVersion]. Any failure here (offline, a Firestore error, an
/// emulator quirk) also resolves to [AppVersionOk] — see that function's
/// doc for why failing open matters.
Future<AppVersionStatus> checkAppVersion(FirebaseFirestore firestore) async {
  try {
    final info = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(info.buildNumber);
    if (currentBuild == null) return const AppVersionOk();

    final snapshot = await firestore.collection('config').doc('appVersion').get();
    return evaluateAppVersion(
      currentBuild: currentBuild,
      platform: defaultTargetPlatform,
      configData: snapshot.data(),
    );
  } catch (_) {
    return const AppVersionOk();
  }
}
