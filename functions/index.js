/**
 * functions/index.js
 *
 * لما رسالة جديدة تتكتب في Firestore، بنبعت إشعار لباقي المشاركين في المحادثة.
 *
 * ⚠️ افتراض: الرسايل متخزنة في  chats/{chatId}/messages/{messageId}
 *    وكل رسالة فيها senderId و text، والـ chat document فيه participants.
 *    لو المسار عندك مختلف، غيّره في سطر document تحت.
 */

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

const MAX_BODY_LENGTH = 120;

exports.onNewChatMessage = onDocumentCreated(
    "chats/{chatId}/messages/{messageId}",
    async (event) => {
      const message = event.data && event.data.data();
      if (!message) return;

      const {chatId} = event.params;
      const senderId = message.senderId;
      const text = String(message.text || "");

      if (!senderId || !text) return;

      const db = getFirestore();

      // المستلمين = كل المشاركين ما عدا المرسل
      const chatSnap = await db.doc(`chats/${chatId}`).get();
      const participants = (chatSnap.data() || {}).participants || [];
      const recipientIds = participants.filter((id) => id !== senderId);
      if (recipientIds.length === 0) return;

      // عداد الرسائل غير المقروءة: +1 لكل مستلم
      // (الموبايل بيصفّره لما المستخدم يفتح المحادثة)
      const unreadUpdates = {};
      recipientIds.forEach((id) => {
        unreadUpdates[`unread.${id}`] = FieldValue.increment(1);
      });
      await db.doc(`chats/${chatId}`).update(unreadUpdates);

      // اسم المرسل يظهر كعنوان للإشعار
      const senderSnap = await db.doc(`users/${senderId}`).get();
      const senderName = (senderSnap.data() || {}).name || "رسالة جديدة";

      const body =
      text.length > MAX_BODY_LENGTH ?
        `${text.slice(0, MAX_BODY_LENGTH - 3)}...` :
        text;

      for (const recipientId of recipientIds) {
        const tokensSnap = await db
            .collection(`users/${recipientId}/fcmTokens`)
            .get();

        // اسم الـ document هو الـ token نفسه
        const tokens = tokensSnap.docs.map((doc) => doc.id);
        if (tokens.length === 0) continue;

        const response = await getMessaging().sendEachForMulticast({
          tokens,
          notification: {title: senderName, body},
          data: {
            type: "chat",
            chatId: String(chatId),
            senderId: String(senderId),
            senderName: String(senderName),
          },
          android: {
            priority: "high",
            notification: {channelId: "chat_messages"},
          },
          apns: {
            payload: {aps: {sound: "default"}},
          },
        });

        // امسح الـ tokens الميتة (تطبيق اتمسح أو اتعمله logout)
        const deadTokens = [];
        response.responses.forEach((result, index) => {
          if (result.success) return;
          const code = result.error && result.error.code;
          if (
            code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token"
          ) {
            deadTokens.push(tokens[index]);
          }
        });

        await Promise.all(
            deadTokens.map((token) =>
              db.doc(`users/${recipientId}/fcmTokens/${token}`).delete(),
            ),
        );
      }
    },
);
