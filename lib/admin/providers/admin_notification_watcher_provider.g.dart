// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_notification_watcher_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watches the five admin moderation/review queues — creator profiles,
/// brand profiles, campaigns awaiting approval, support tickets, and
/// reports/blocks — and fires a desktop notification (with a
/// category-specific sound, see [BrowserNotificationService]) for every
/// item that newly needs attention.
///
/// `keepAlive: true` and watched once from `AdminShell` so this runs for
/// as long as an admin/staff member is signed in, across every screen —
/// it never needs to be watched again elsewhere.

@ProviderFor(adminNotificationWatcher)
final adminNotificationWatcherProvider = AdminNotificationWatcherProvider._();

/// Watches the five admin moderation/review queues — creator profiles,
/// brand profiles, campaigns awaiting approval, support tickets, and
/// reports/blocks — and fires a desktop notification (with a
/// category-specific sound, see [BrowserNotificationService]) for every
/// item that newly needs attention.
///
/// `keepAlive: true` and watched once from `AdminShell` so this runs for
/// as long as an admin/staff member is signed in, across every screen —
/// it never needs to be watched again elsewhere.

final class AdminNotificationWatcherProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Watches the five admin moderation/review queues — creator profiles,
  /// brand profiles, campaigns awaiting approval, support tickets, and
  /// reports/blocks — and fires a desktop notification (with a
  /// category-specific sound, see [BrowserNotificationService]) for every
  /// item that newly needs attention.
  ///
  /// `keepAlive: true` and watched once from `AdminShell` so this runs for
  /// as long as an admin/staff member is signed in, across every screen —
  /// it never needs to be watched again elsewhere.
  AdminNotificationWatcherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminNotificationWatcherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminNotificationWatcherHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return adminNotificationWatcher(ref);
  }
}

String _$adminNotificationWatcherHash() =>
    r'8c608ae59d23ac49d4d1b6f6e97859cb90ccdd64';
