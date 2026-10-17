"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onChatMessageCreated = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const firestore_2 = require("firebase-admin/firestore");
const createNotificationIfNew_1 = require("./createNotificationIfNew");
/** Mirrors `chat_repository.dart`'s `sendMessage` notification — same
 * 80-char truncation so the body text (and therefore the dedupe check in
 * `createNotificationIfNew`) matches byte-for-byte against what an
 * old-build client would have written for the same message. */
exports.onChatMessageCreated = (0, firestore_1.onDocumentCreated)("chats/{chatId}/messages/{messageId}", async (event) => {
    const message = event.data?.data();
    if (!message)
        return;
    const chatDoc = await (0, firestore_2.getFirestore)()
        .collection("chats")
        .doc(event.params.chatId)
        .get();
    const chat = chatDoc.data();
    if (!chat)
        return;
    const senderId = message.senderId;
    const isCreatorSender = senderId === chat.creatorId;
    const recipientId = isCreatorSender ? chat.brandId : chat.creatorId;
    const senderName = isCreatorSender ? chat.creatorName : chat.brandName;
    if (!recipientId)
        return;
    const text = message.text ?? "";
    const truncated = text.length > 80 ? `${text.substring(0, 80)}…` : text;
    await (0, createNotificationIfNew_1.createNotificationIfNew)({
        userId: recipientId,
        type: "newMessage",
        title: "New message",
        body: `${senderName ?? "Someone"}: ${truncated}`,
        referenceType: "chat",
        referenceId: event.params.chatId,
    });
});
