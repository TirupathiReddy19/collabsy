import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/firebase_service.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/utils/creator_display_name.dart';
import '../../auth/providers/auth_providers.dart';
import '../../brand/providers/brand_profile_providers.dart';
import '../../settings/providers/instagram_providers.dart';
import '../data/chat_repository.dart';
import '../models/chat.dart';
import '../models/chat_message.dart';

part 'chat_providers.g.dart';

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  return ChatRepository(ref.watch(firestoreProvider));
}

/// A one-shot draft stashed just before navigating to a chat (e.g. creator
/// tapping "Message" pre-fills a starter line, optionally attached to a
/// campaign) — read and cleared by the chat screen's `initState`. Kept in
/// provider state rather than passed via GoRouter `extra`, which the
/// router's own redirect-driven navigation can silently drop.
typedef ChatDraft = ({String text, String? campaignId});

@Riverpod(keepAlive: true)
class PendingChatDraft extends _$PendingChatDraft {
  @override
  ChatDraft? build() => null;

  void set(ChatDraft? value) => state = value;
}

/// The signed-in user's chat threads — whichever side of the pair they are.
@Riverpod(keepAlive: true)
Stream<List<Chat>> myChats(Ref ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  final profile = ref.watch(currentProfileProvider).value;
  if (user == null || profile?.role == null) return Stream.value(const []);
  final repository = ref.watch(chatRepositoryProvider);
  return profile!.role == UserRole.creator
      ? repository.watchChatsForCreator(user.uid)
      : repository.watchChatsForBrand(user.uid);
}

@riverpod
Future<Chat?> chatById(Ref ref, String chatId) {
  return ref.watch(chatRepositoryProvider).fetchChat(chatId);
}

@riverpod
Stream<List<ChatMessage>> chatMessages(Ref ref, String chatId) {
  return ref.watch(chatRepositoryProvider).watchMessages(chatId);
}

/// Drives sending messages and marking a thread read.
@Riverpod(keepAlive: true)
class ChatController extends _$ChatController {
  @override
  FutureOr<void> build() {}

  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? campaignId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw StateError('No active session to send a message with.');
      }
      await ref
          .read(chatRepositoryProvider)
          .sendMessage(
            chatId: chatId,
            senderId: user.uid,
            text: text,
            campaignId: campaignId,
          );
    });
  }

  Future<void> markRead({required String chatId, required bool isCreator}) {
    return ref
        .read(chatRepositoryProvider)
        .markRead(chatId: chatId, isCreator: isCreator);
  }

  /// Creator messaging a brand they haven't been accepted by yet — starts
  /// in Requests. There's only ever one thread per brand+creator pair, so
  /// this is safe to call from any campaign context.
  Future<String?> startChatAsCreator({
    required String brandId,
    required String brandName,
  }) async {
    state = const AsyncLoading();
    String? chatId;
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      final user = authRepository.currentUser;
      if (user == null) {
        throw StateError('No active session to message from.');
      }
      final profile = await authRepository.fetchProfile(user.uid);
      final instagramAccount = await ref
          .read(instagramRepositoryProvider)
          .watchAccount(user.uid)
          .first;
      chatId = await ref
          .read(chatRepositoryProvider)
          .startChatAsCreator(
            creatorId: user.uid,
            creatorName: creatorDisplayName(
              profile?.displayName,
              instagramAccount,
            ),
            brandId: brandId,
            brandName: brandName,
          );
    });
    return chatId;
  }

  /// Brand messaging an applicant directly from the applications list — an
  /// application already exists, so this starts directly in Messages
  /// rather than Requests.
  Future<String?> startChatAsBrand({
    required String creatorId,
    required String creatorName,
  }) async {
    state = const AsyncLoading();
    String? chatId;
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      final user = authRepository.currentUser;
      if (user == null) {
        throw StateError('No active session to message from.');
      }
      final profile = await authRepository.fetchProfile(user.uid);
      final brandProfile = await ref
          .read(brandProfileRepositoryProvider)
          .fetchBrandProfile(user.uid);
      chatId = await ref
          .read(chatRepositoryProvider)
          .startChatAsBrand(
            creatorId: creatorId,
            creatorName: creatorName,
            brandId: user.uid,
            brandName:
                brandProfile?.companyName ?? profile?.displayName ?? 'Brand',
          );
    });
    return chatId;
  }

  /// Brand messaging a creator directly from Discover — no application or
  /// campaign relationship exists yet, starts in Requests.
  Future<String?> startGeneralChat({
    required String creatorId,
    required String creatorName,
  }) async {
    state = const AsyncLoading();
    String? chatId;
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      final user = authRepository.currentUser;
      if (user == null) {
        throw StateError('No active session to message from.');
      }
      final profile = await authRepository.fetchProfile(user.uid);
      final brandProfile = await ref
          .read(brandProfileRepositoryProvider)
          .fetchBrandProfile(user.uid);
      chatId = await ref
          .read(chatRepositoryProvider)
          .startGeneralChat(
            brandId: user.uid,
            brandName:
                brandProfile?.companyName ?? profile?.displayName ?? 'Brand',
            creatorId: creatorId,
            creatorName: creatorName,
          );
    });
    return chatId;
  }
}
