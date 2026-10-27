
/**
 * functions/index.js
 *
 * - يحفظ إشعارًا داخل users/{uid}/notifications.
 * - يرسل FCM إذا كانت إشعارات الشات مفعّلة للمستخدم.
 * - يحافظ على عداد الرسائل غير المقروءة.
 * - يحذف FCM tokens غير الصالحة.
 */

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const {
  getFirestore,
  FieldValue,
} = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const MAX_BODY_LENGTH = 120;

exports.onNewChatMessage = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const message = event.data?.data();
    if (!message) return;

    const { chatId, messageId } = event.params;
    const senderId = message.senderId;
    const text = String(message.text || "");

    if (!senderId || !text.trim()) return;

    const db = getFirestore();

    // تحديد المستلمين.
    const chatSnap = await db.doc(`chats/${chatId}`).get();

    const participants = chatSnap.data()?.participants || [];
    const recipientIds = participants.filter(
      (id) => id !== senderId,
    );

    if (recipientIds.length === 0) return;

    // تحديث عداد الرسائل غير المقروءة.
    const unreadUpdates = {};

    recipientIds.forEach((id) => {
      unreadUpdates[`unread.${id}`] = FieldValue.increment(1);
    });

    await db.doc(`chats/${chatId}`).update(unreadUpdates);

    // بيانات المرسل.
    const senderSnap = await db.doc(`users/${senderId}`).get();
    const senderName = senderSnap.data()?.name || "رسالة جديدة";

    const body =
      text.length > MAX_BODY_LENGTH
        ? `${text.slice(0, MAX_BODY_LENGTH - 3)}...`
        : text;

    // معالجة كل مستلم.
    for (const recipientId of recipientIds) {
      try {
        const userRef = db.doc(`users/${recipientId}`);
        const userSnap = await userRef.get();

        // حفظ سجل الإشعار حتى لو لم يكن لدى المستخدم FCM token.
        // استخدام ID ثابت يمنع تكرار سجل الإشعار عند إعادة المحاولة.
        const notificationId = `${chatId}_${messageId}`;

        await userRef
          .collection("notifications")
          .doc(notificationId)
          .set(
            {
              type: "chat",
              title: senderName,
              body,
              senderId: String(senderId),
              senderName: String(senderName),
              chatId: String(chatId),
              messageId: String(messageId),
              createdAt: FieldValue.serverTimestamp(),
              isRead: false,
            },
            { merge: true },
          );

        // احترام إعدادات المستخدم.
        const settings =
          userSnap.data()?.notificationSettings || {};

        // الافتراضي مفعّل إذا لم توجد إعدادات محفوظة.
        const chatNotificationsEnabled =
          settings.chatMessages !== false;

        if (!chatNotificationsEnabled) {
          console.log(
            `Chat push disabled for user ${recipientId}`,
          );
          continue;
        }

        // جلب أجهزة المستخدم.
        const tokensSnap = await db
          .collection(`users/${recipientId}/fcmTokens`)
          .get();

        const tokens = tokensSnap.docs.map((doc) => doc.id);

        if (tokens.length === 0) continue;

        // إرسال إشعار الجهاز.
        const response = await getMessaging().sendEachForMulticast({
          tokens,
          notification: {
            title: senderName,
            body,
          },
          data: {
            type: "chat",
            chatId: String(chatId),
            messageId: String(messageId),
            senderId: String(senderId),
            senderName: String(senderName),
          },
          android: {
            priority: "high",
            notification: {
              channelId: "chat_messages",
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
              },
            },
          },
        });

        // حذف الأجهزة التي لم تعد tokens الخاصة بها صالحة.
        const deadTokens = [];

        response.responses.forEach((result, index) => {
          if (result.success) return;

          const code = result.error?.code;

          if (
            code === "messaging/registration-token-not-registered" ||
            code === "messaging/invalid-registration-token"
          ) {
            deadTokens.push(tokens[index]);
          }
        });

        await Promise.all(
          deadTokens.map((token) =>
            db
              .doc(`users/${recipientId}/fcmTokens/${token}`)
              .delete(),
          ),
        );
      } catch (error) {
        console.error(
          `Failed to process notification for ${recipientId}:`,
          error,
        );
      }
    }
  },
);
