// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(firebaseMessaging)
final firebaseMessagingProvider = FirebaseMessagingProvider._();

final class FirebaseMessagingProvider
    extends
        $FunctionalProvider<
          FirebaseMessaging,
          FirebaseMessaging,
          FirebaseMessaging
        >
    with $Provider<FirebaseMessaging> {
  FirebaseMessagingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseMessagingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseMessagingHash();

  @$internal
  @override
  $ProviderElement<FirebaseMessaging> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseMessaging create(Ref ref) {
    return firebaseMessaging(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseMessaging value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseMessaging>(value),
    );
  }
}

String _$firebaseMessagingHash() => r'6765ce963b9b8c50186b5132356d60eb68265741';

@ProviderFor(pushNotificationService)
final pushNotificationServiceProvider = PushNotificationServiceProvider._();

final class PushNotificationServiceProvider
    extends
        $FunctionalProvider<
          PushNotificationService,
          PushNotificationService,
          PushNotificationService
        >
    with $Provider<PushNotificationService> {
  PushNotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushNotificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushNotificationServiceHash();

  @$internal
  @override
  $ProviderElement<PushNotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PushNotificationService create(Ref ref) {
    return pushNotificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushNotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushNotificationService>(value),
    );
  }
}

String _$pushNotificationServiceHash() =>
    r'617965bf2e86551a45f7a028e7fb97ad648bb75f';
