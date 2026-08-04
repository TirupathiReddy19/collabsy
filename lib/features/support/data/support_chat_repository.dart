import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../shared/models/user_role.dart';
import '../models/support_chat.dart';
import '../models/support_chat_status.dart';
import '../models/support_message.dart';
import '../models/support_ticket_category.dart';

/// The only place that talks to the `supportChats` Firestore collection
/// directly — kept entirely separate from `ChatRepository`/`chats`
/// (Creator<->Brand messaging), per the deliberate decision not to mix the
/// two systems. One doc per *ticket* (auto-generated id) — a user can have
/// many over time, so a resolved ticket stays as history rather than being
/// overwritten by the next conversation.
class SupportChatRepository {
  SupportChatRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('supportChats');

  /// Starts a brand-new ticket (a fresh number) — called once the caller
  /// has already decided there's no still-open ticket to resume (see
  /// [findOpenTicketId]). Returns the new ticket's id.
  Future<String> createTicket({
    required String userId,
    required String userName,
    required UserRole userRole,
  }) async {
    final ref = _chats.doc();
    await ref.set({
      'userId': userId,
      'userName': userName,
      'userRole': userRole.toDbValue(),
      'status': SupportChatStatus.open.toDbValue(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// The user's own still-open ticket, if any — so contacting support
  /// resumes an existing conversation instead of always starting a new one.
  Future<String?> findOpenTicketId(String userId) async {
    final snapshot = await _chats
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: SupportChatStatus.open.toDbValue())
        .limit(1)
        .get();
    return snapshot.docs.isEmpty ? null : snapshot.docs.first.id;
  }

  Stream<SupportChat?> watchChat(String ticketId) {
    return _chats.doc(ticketId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return SupportChat.fromJson(_withLegacyUserId(doc));
    });
  }

  /// Tickets from before tickets had their own auto-generated id (the doc
  /// id used to just be the owning user's uid) never got a `userId` field
  /// written — this fills it in from the doc id itself, which is exactly
  /// what that field would have been, so old tickets still parse instead of
  /// throwing on the now-required field.
  Map<String, dynamic> _withLegacyUserId(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return {...data, 'id': doc.id, 'userId': data['userId'] ?? doc.id};
  }

  /// Every ticket for one user, newest first — the mobile-side ticket
  /// history list.
  Stream<List<SupportChat>> watchUserTickets(String userId) {
    return _chats.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final tickets = snapshot.docs
          .map((doc) => SupportChat.fromJson(_withLegacyUserId(doc)))
          .toList();
      tickets.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(0);
        final bTime = b.createdAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
      return tickets;
    });
  }

  /// Every ticket across every user — for the Admin's Support Tickets list.
  Stream<List<SupportChat>> watchAllChats() {
    return _chats.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => SupportChat.fromJson(_withLegacyUserId(doc)))
          .toList(),
    );
  }

  Stream<List<SupportMessage>> watchMessages(String ticketId) {
    return _chats
        .doc(ticketId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => SupportMessage.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  /// [userId] is who the ticket belongs to — no longer derivable from
  /// [ticketId] itself, since a ticket id is now an auto-generated id, not
  /// the uid. Needed for the attachment's storage path and (for a support
  /// reply) who to notify.
  Future<void> sendMessage({
    required String ticketId,
    required String userId,
    required SupportSenderRole senderRole,
    required String text,
    File? image,
  }) async {
    final chatRef = _chats.doc(ticketId);
    final messageRef = chatRef.collection('messages').doc();

    String? imageUrl;
    if (image != null) {
      final storageRef = _storage.ref(
        'supportChats/$ticketId/attachments/${messageRef.id}.jpg',
      );
      await storageRef.putFile(
        image,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      imageUrl = await storageRef.getDownloadURL();
    }

    await messageRef.set({
      'senderRole': senderRole.toDbValue(),
      'text': text,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'sentAt': FieldValue.serverTimestamp(),
    });
    await chatRef.update({
      'lastMessage': text.isNotEmpty ? text : 'Sent an image',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageSenderRole': senderRole.toDbValue(),
    });

    // Only a support reply needs a notification — the admin sees new user
    // messages live in the Support Tickets list, no separate channel needed.
    if (senderRole == SupportSenderRole.support) {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': 'supportReply',
        'title': 'Support replied',
        'body': text.length > 80 ? '${text.substring(0, 80)}…' : text,
        'referenceType': 'support',
        'referenceId': ticketId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> markRead({required String ticketId, required bool asAdmin}) {
    return _chats.doc(ticketId).update({
      asAdmin ? 'supportLastReadAt' : 'userLastReadAt':
          FieldValue.serverTimestamp(),
    });
  }

  Future<void> setStatus({
    required String ticketId,
    required SupportChatStatus status,
  }) {
    return _chats.doc(ticketId).update({'status': status.toDbValue()});
  }

  /// Admin/staff-only triage tag — blocked for the ticket's own user by
  /// `firestore.rules`, regardless of what a tampered client sends.
  Future<void> setCategory({
    required String ticketId,
    required SupportTicketCategory category,
  }) {
    return _chats.doc(ticketId).update({'category': category.toDbValue()});
  }

  /// Admin/staff-only freeform note, never visible to the ticket's own user
  /// — same rule boundary as `setCategory`.
  Future<void> setInternalNotes({
    required String ticketId,
    required String notes,
    required String updatedByEmail,
  }) {
    return _chats.doc(ticketId).update({
      'internalNotes': notes,
      'internalNotesUpdatedAt': FieldValue.serverTimestamp(),
      'internalNotesUpdatedBy': updatedByEmail,
    });
  }
}
