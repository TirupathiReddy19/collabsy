import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/firebase_service.dart';
import '../../../shared/models/user_role.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/blocking_repository.dart';
import '../models/block.dart';
import '../models/report_reason.dart';

part 'blocking_providers.g.dart';

@Riverpod(keepAlive: true)
BlockingRepository blockingRepository(Ref ref) {
  return BlockingRepository(ref.watch(firestoreProvider));
}

/// Everyone the signed-in user has blocked, newest first — feeds the
/// Settings "Blocked accounts" screen.
@Riverpod(keepAlive: true)
Stream<List<Block>> myBlockedUsers(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(blockingRepositoryProvider).watchBlockedByMe(uid);
}

/// Whether the signed-in user and [otherId] have a block between them in
/// either direction — feeds the chat-input/menu gating.
@riverpod
Future<bool> isBlockedEitherWay(Ref ref, String otherId) async {
  final uid = ref.watch(authRepositoryProvider).currentUser?.uid;
  if (uid == null) return false;
  return ref.watch(blockingRepositoryProvider).isBlockedEitherWay(uid, otherId);
}

@Riverpod(keepAlive: true)
class BlockingController extends _$BlockingController {
  @override
  FutureOr<void> build() {}

  Future<void> block({
    required String blockedId,
    required UserRole blockedRole,
  }) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    final myRole = ref.read(currentProfileProvider).value?.role;
    if (user == null || myRole == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(blockingRepositoryProvider)
          .block(
            blockerId: user.uid,
            blockerRole: myRole,
            blockedId: blockedId,
            blockedRole: blockedRole,
          ),
    );
    ref.invalidate(isBlockedEitherWayProvider(blockedId));
  }

  Future<void> unblock(String blockedId) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(blockingRepositoryProvider)
          .unblock(blockerId: user.uid, blockedId: blockedId),
    );
    ref.invalidate(isBlockedEitherWayProvider(blockedId));
  }

  Future<void> report({
    required String reportedId,
    required UserRole reportedRole,
    String? reportedName,
    required ReportReason reason,
    String? details,
    String? chatId,
  }) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    final myRole = ref.read(currentProfileProvider).value?.role;
    if (user == null || myRole == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(blockingRepositoryProvider)
          .report(
            reporterId: user.uid,
            reporterRole: myRole,
            reportedId: reportedId,
            reportedRole: reportedRole,
            reportedName: reportedName,
            reason: reason,
            details: details,
            chatId: chatId,
          ),
    );
  }
}
