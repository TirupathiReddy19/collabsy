import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/providers/auth_providers.dart';

part 'push_notification_service.g.dart';

@Riverpod(keepAlive: true)
FirebaseMessaging firebaseMessaging(Ref ref) => FirebaseMessaging.instance;

/// Requests notification permission, grabs the device's FCM token, and
/// keeps it saved on `users/{uid}.fcmToken` — that's the only piece the
/// Cloud Function needs to actually deliver a push for a given user.
///
/// Deliberately request-and-forget: if the user denies permission, or the
/// token can't be fetched (emulator without Play services, etc.), the app
/// still works — the user just won't get OS push, only the in-app feed.
class PushNotificationService {
  PushNotificationService(this._messaging, this._authRepository);

  final FirebaseMessaging _messaging;
  final AuthRepository _authRepository;

  Future<void> initialize(String userId) async {
    try {
      final settings = await _messaging.requestPermission();
      final token = await _messaging.getToken();
      debugPrint(
        'Push notification setup: authorizationStatus='
        '${settings.authorizationStatus}, token='
        '${token == null ? "null" : "${token.substring(0, 12)}…"}',
      );
      if (token != null) {
        await _authRepository.saveFcmToken(userId: userId, token: token);
      } else if (!kDebugMode) {
        // No token means the push-sending Cloud Function will silently
        // find nothing to send to later - worth knowing when/why that
        // happens (denied permission, APNs not registered yet, etc.)
        // rather than only discovering it from "the user never got a
        // push" reports with nothing to go on.
        FirebaseCrashlytics.instance.recordError(
          StateError('FCM getToken() returned null'),
          StackTrace.current,
          reason:
              'Push notification setup: no token - authorizationStatus='
              '${settings.authorizationStatus}',
          fatal: false,
        );
      }
      _messaging.onTokenRefresh.listen((newToken) {
        _authRepository.saveFcmToken(userId: userId, token: newToken);
      });
    } catch (error, stackTrace) {
      debugPrint('Push notification setup failed: $error');
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Push notification setup failed: $error',
          fatal: false,
        );
      }
    }
  }
}

@Riverpod(keepAlive: true)
PushNotificationService pushNotificationService(Ref ref) {
  return PushNotificationService(
    ref.watch(firebaseMessagingProvider),
    ref.watch(authRepositoryProvider),
  );
}
