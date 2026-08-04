import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/firebase_service.dart';
import '../../../shared/models/user_role.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/support_chat_repository.dart';
import '../models/support_chat.dart';
import '../models/support_message.dart';

part 'support_chat_providers.g.dart';

@Riverpod(keepAlive: true)
SupportChatRepository supportChatRepository(Ref ref) {
  return SupportChatRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseStorageProvider),
  );
}

/// A specific ticket, by id — shared by the mobile chat screen (its own
/// ticket) and the Admin's Support Ticket detail screen (any ticket).
@riverpod
Stream<SupportChat?> supportTicket(Ref ref, String ticketId) {
  return ref.watch(supportChatRepositoryProvider).watchChat(ticketId);
}

@riverpod
Stream<List<SupportMessage>> supportTicketMessages(Ref ref, String ticketId) {
  return ref.watch(supportChatRepositoryProvider).watchMessages(ticketId);
}

/// Every ticket belonging to the signed-in user, newest first — the
/// mobile-side ticket history screen.
@riverpod
Stream<List<SupportChat>> userTickets(Ref ref, String userId) {
  return ref.watch(supportChatRepositoryProvider).watchUserTickets(userId);
}

/// Every ticket across every user — for the Admin's Support Tickets list.
@Riverpod(keepAlive: true)
Stream<List<SupportChat>> allSupportChats(Ref ref) {
  return ref.watch(supportChatRepositoryProvider).watchAllChats();
}

/// Drives the user-facing Help/chat screens: resolving which ticket to open
/// and sending messages as themselves.
@Riverpod(keepAlive: true)
class SupportChatController extends _$SupportChatController {
  @override
  FutureOr<void> build() {}

  /// What "Contact support" resolves to — the user's still-open ticket if
  /// one exists, otherwise a brand-new one (a fresh ticket number).
  Future<String?> startOrResumeTicket() async {
    final authRepository = ref.read(authRepositoryProvider);
    final user = authRepository.currentUser;
    if (user == null) return null;

    final repository = ref.read(supportChatRepositoryProvider);
    final openTicketId = await repository.findOpenTicketId(user.uid);
    if (openTicketId != null) return openTicketId;

    final profile = await authRepository.fetchProfile(user.uid);
    return repository.createTicket(
      userId: user.uid,
      userName: profile?.displayName ?? 'User',
      userRole: profile?.role ?? UserRole.creator,
    );
  }

  Future<void> sendMessage(String ticketId, String text, {File? image}) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(supportChatRepositoryProvider)
          .sendMessage(
            ticketId: ticketId,
            userId: user.uid,
            senderRole: SupportSenderRole.user,
            text: text,
            image: image,
          ),
    );
  }
}
