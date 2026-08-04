import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/firebase_service.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/notifications_repository.dart';
import '../models/app_notification.dart';

part 'notifications_providers.g.dart';

@Riverpod(keepAlive: true)
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepository(ref.watch(firestoreProvider));
}

@Riverpod(keepAlive: true)
Stream<List<AppNotification>> myNotifications(Ref ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return Stream.value(const []);
  return ref.watch(notificationsRepositoryProvider).watchForUser(user.uid);
}

@Riverpod(keepAlive: true)
int unreadNotificationsCount(Ref ref) {
  final items = ref.watch(myNotificationsProvider).value ?? const [];
  return items.where((n) => !n.read).length;
}

@Riverpod(keepAlive: true)
class NotificationController extends _$NotificationController {
  @override
  FutureOr<void> build() {}

  Future<void> markRead(String notificationId) async {
    try {
      await ref.read(notificationsRepositoryProvider).markRead(notificationId);
    } catch (_) {
      // Best-effort — a failed read-mark shouldn't block navigation.
    }
  }

  Future<void> markAllRead() async {
    final unreadIds = (ref.read(myNotificationsProvider).value ?? const [])
        .where((n) => !n.read)
        .map((n) => n.id)
        .toList();
    try {
      await ref.read(notificationsRepositoryProvider).markAllRead(unreadIds);
    } catch (_) {
      // Best-effort.
    }
  }
}
