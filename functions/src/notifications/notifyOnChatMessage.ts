import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getFirestore } from "firebase-admin/firestore";

import { createNotificationIfNew } from "./createNotificationIfNew";

/** Mirrors `chat_repository.dart`'s `sendMessage` notification — same
 * 80-char truncation so the body text (and therefore the dedupe check in
 * `createNotificationIfNew`) matches byte-for-byte against what an
 * old-build client would have written for the same message. */
export const onChatMessageCreated = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const message = event.data?.data();
    if (!message) return;

    const chatDoc = await getFirestore()
      .collection("chats")
      .doc(event.params.chatId)
      .get();
    const chat = chatDoc.data();
    if (!chat) return;

    const senderId = message.senderId as string;
    const isCreatorSender = senderId === chat.creatorId;
    const recipientId = isCreatorSender ? chat.brandId : chat.creatorId;
    const senderName = isCreatorSender ? chat.creatorName : chat.brandName;
    if (!recipientId) return;

    const text = (message.text as string) ?? "";
    const truncated = text.length > 80 ? `${text.substring(0, 80)}…` : text;

    await createNotificationIfNew({
      userId: recipientId,
      type: "newMessage",
      title: "New message",
      body: `${senderName ?? "Someone"}: ${truncated}`,
      referenceType: "chat",
      referenceId: event.params.chatId,
    });
  }
);
