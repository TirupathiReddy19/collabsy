import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat.dart';
import '../models/chat_message.dart';
import '../models/chat_status.dart';

/// The only place in the `chat` feature that talks to Firestore directly.
///
/// One chat thread ever exists per brand+creator pair — it's a property of
/// the relationship between the two profiles, not of any particular
/// campaign. Every "does this chat already exist" check here is a QUERY
/// filtered by plain data fields equal to the caller's own uid (e.g.
/// creatorId == caller) rather than a direct `.doc(id).get()` — the
/// security rule can't evaluate a direct read for a document that might not
/// exist yet (resource is null, so resource.data.creatorId errors out and
/// the whole read gets denied), but a query constrained that way is
/// something the rule CAN verify up front regardless of whether anything
/// matches. Deliberately never combines a `FieldPath.documentId` filter, or
/// a `null`-equality filter, with a data field filter here — Firestore's
/// list-query rule validator cannot prove safety for either combination
/// (confirmed via PERMISSION_DENIED in practice for both).
class ChatRepository {
  ChatRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  /// Deterministic — a brand+creator pair only ever has one thread, however
  /// many campaigns they collaborate on together.
  String chatId(String brandId, String creatorId) => '${brandId}_$creatorId';

  /// Creator messaging a brand they haven't been accepted by yet. Starts as
  /// [ChatStatus.request]. If a thread already exists for this pair (e.g.
  /// it was already upgraded to active), this leaves it untouched and just
  /// returns its ID.
  Future<String> startChatAsCreator({
    required String creatorId,
    required String creatorName,
    required String brandId,
    required String brandName,
  }) async {
    final existing = await _chats
        .where('creatorId', isEqualTo: creatorId)
        .where('brandId', isEqualTo: brandId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return existing.docs.first.id;
    final id = chatId(brandId, creatorId);
    await _chats.doc(id).set({
      'creatorId': creatorId,
      'creatorName': creatorName,
      'brandId': brandId,
      'brandName': brandName,
      'status': ChatStatus.request.toDbValue(),
      'initiatedBy': 'creator',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return id;
  }

  /// Brand messaging a creator directly from the applications list — an
  /// application already exists, so this starts directly in Messages
  /// rather than Requests. If a thread already exists for this pair, this
  /// leaves it untouched and just returns its ID (it never demotes an
  /// already-active thread).
  Future<String> startChatAsBrand({
    required String creatorId,
    required String creatorName,
    required String brandId,
    required String brandName,
  }) async {
    final existing = await _chats
        .where('creatorId', isEqualTo: creatorId)
        .where('brandId', isEqualTo: brandId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return existing.docs.first.id;
    final id = chatId(brandId, creatorId);
    await _chats.doc(id).set({
      'creatorId': creatorId,
      'creatorName': creatorName,
      'brandId': brandId,
      'brandName': brandName,
      'status': ChatStatus.active.toDbValue(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return id;
  }

  /// Brand messaging a creator directly from Discover — no application or
  /// campaign relationship exists yet, so this starts as
  /// [ChatStatus.request] rather than jumping straight to Messages.
  Future<String> startGeneralChat({
    required String brandId,
    required String brandName,
    required String creatorId,
    required String creatorName,
  }) async {
    final existing = await _chats
        .where('creatorId', isEqualTo: creatorId)
        .where('brandId', isEqualTo: brandId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return existing.docs.first.id;
    final id = chatId(brandId, creatorId);
    await _chats.doc(id).set({
      'creatorId': creatorId,
      'creatorName': creatorName,
      'brandId': brandId,
      'brandName': brandName,
      'status': ChatStatus.request.toDbValue(),
      'initiatedBy': 'brand',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return id;
  }

  /// Called when a brand accepts a creator's application: creates the
  /// brand+creator's one thread as active if it doesn't exist yet, or
  /// upgrades an existing request-status thread (from the creator
  /// messaging first) into Messages. Also what backfills a chat for an
  /// application that was accepted before this feature existed — safe to
  /// call every time that application's detail screen is viewed, since
  /// it's a no-op once active.
  ///
  /// Split by caller role (mirroring the start*Chat methods) because the
  /// existence-check query must filter on a field equal to the CALLER's own
  /// uid for the security rule to validate it — a query filtered by brandId
  /// is rejected when a creator is the one calling it, and vice versa.
  Future<String> ensureActiveChatAsBrand({
    required String creatorId,
    required String creatorName,
    required String brandId,
    required String brandName,
  }) async {
    final existing = await _chats
        .where('brandId', isEqualTo: brandId)
        .where('creatorId', isEqualTo: creatorId)
        .limit(1)
        .get();
    return _ensureActiveChat(
      existing: existing,
      creatorId: creatorId,
      creatorName: creatorName,
      brandId: brandId,
      brandName: brandName,
    );
  }

  Future<String> ensureActiveChatAsCreator({
    required String creatorId,
    required String creatorName,
    required String brandId,
    required String brandName,
  }) async {
    final existing = await _chats
        .where('creatorId', isEqualTo: creatorId)
        .where('brandId', isEqualTo: brandId)
        .limit(1)
        .get();
    return _ensureActiveChat(
      existing: existing,
      creatorId: creatorId,
      creatorName: creatorName,
      brandId: brandId,
      brandName: brandName,
    );
  }

  Future<String> _ensureActiveChat({
    required QuerySnapshot<Map<String, dynamic>> existing,
    required String creatorId,
    required String creatorName,
    required String brandId,
    required String brandName,
  }) async {
    if (existing.docs.isEmpty) {
      final id = chatId(brandId, creatorId);
      await _chats.doc(id).set({
        'creatorId': creatorId,
        'creatorName': creatorName,
        'brandId': brandId,
        'brandName': brandName,
        'status': ChatStatus.active.toDbValue(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return id;
    }
    final doc = existing.docs.first;
    if (ChatStatus.fromDbValue(doc.data()['status'] as String?) !=
        ChatStatus.active) {
      await doc.reference.update({'status': ChatStatus.active.toDbValue()});
    }
    return doc.id;
  }

  Stream<List<Chat>> watchChatsForCreator(String creatorId) {
    return _chats
        .where('creatorId', isEqualTo: creatorId)
        .snapshots()
        .map(
          (snapshot) => _dedupeByOtherParty(
            snapshot.docs
                .map((doc) => Chat.fromJson({...doc.data(), 'id': doc.id}))
                .toList(),
            keyOf: (chat) => chat.brandId,
          ),
        );
  }

  Stream<List<Chat>> watchChatsForBrand(String brandId) {
    return _chats
        .where('brandId', isEqualTo: brandId)
        .snapshots()
        .map(
          (snapshot) => _dedupeByOtherParty(
            snapshot.docs
                .map((doc) => Chat.fromJson({...doc.data(), 'id': doc.id}))
                .toList(),
            keyOf: (chat) => chat.creatorId,
          ),
        );
  }

  /// Collapses multiple chat documents for the same relationship (leftover
  /// from before a single thread per brand+creator pair was enforced) down
  /// to one — preferring the active/Messages one over a Requests one, and
  /// otherwise the one with the most recent activity.
  List<Chat> _dedupeByOtherParty(
    List<Chat> chats, {
    required String Function(Chat) keyOf,
  }) {
    final byOtherParty = <String, Chat>{};
    for (final chat in chats) {
      final key = keyOf(chat);
      final current = byOtherParty[key];
      if (current == null || _isPreferred(chat, over: current)) {
        byOtherParty[key] = chat;
      }
    }
    return byOtherParty.values.toList();
  }

  bool _isPreferred(Chat candidate, {required Chat over}) {
    if (candidate.status != over.status) {
      return candidate.status == ChatStatus.active;
    }
    final candidateAt = candidate.lastMessageAt;
    final overAt = over.lastMessageAt;
    if (candidateAt == null) return false;
    if (overAt == null) return true;
    return candidateAt.isAfter(overAt);
  }

  Future<Chat?> fetchChat(String id) async {
    final doc = await _chats.doc(id).get();
    if (!doc.exists) return null;
    return Chat.fromJson({...doc.data()!, 'id': doc.id});
  }

  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? campaignId,
  }) async {
    final chatRef = _chats.doc(chatId);
    await chatRef.collection('messages').add({
      'senderId': senderId,
      'text': text,
      if (campaignId != null) 'campaignId': campaignId,
      'sentAt': FieldValue.serverTimestamp(),
    });

    final updates = <String, dynamic>{
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    };

    // A reply from whoever DIDN'T start the thread promotes it out of
    // Requests — the initiator's own follow-up messages don't count, only
    // the other side actually responding does.
    final chatData = (await chatRef.get()).data();
    if (chatData != null) {
      final isCreatorSender = senderId == chatData['creatorId'];
      if (ChatStatus.fromDbValue(chatData['status'] as String?) ==
          ChatStatus.request) {
        final initiatedBy = chatData['initiatedBy'] as String?;
        final senderRole = isCreatorSender ? 'creator' : 'brand';
        if (initiatedBy != null && senderRole != initiatedBy) {
          updates['status'] = ChatStatus.active.toDbValue();
        }
      }
      final recipientId = isCreatorSender
          ? chatData['brandId'] as String?
          : chatData['creatorId'] as String?;
      final senderName = isCreatorSender
          ? chatData['creatorName'] as String?
          : chatData['brandName'] as String?;
      if (recipientId != null) {
        await _firestore.collection('notifications').add({
          'userId': recipientId,
          'type': 'newMessage',
          'title': 'New message',
          'body':
              '${senderName ?? 'Someone'}: '
              '${text.length > 80 ? '${text.substring(0, 80)}…' : text}',
          'referenceType': 'chat',
          'referenceId': chatId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await chatRef.update(updates);
  }

  Future<void> markRead({required String chatId, required bool isCreator}) {
    return _chats.doc(chatId).update({
      isCreator ? 'creatorLastReadAt' : 'brandLastReadAt':
          FieldValue.serverTimestamp(),
    });
  }
}
