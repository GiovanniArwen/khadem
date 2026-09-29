const express = require("express");
const cors = require("cors");
const admin = require("firebase-admin");

const app = express();

app.use(cors());
app.use(express.json());

/*
 * Firebase Admin
 *
 * هنحط الـ Service Account JSON في Render كـ Environment Variable
 * باسم FIREBASE_SERVICE_ACCOUNT_JSON
 */
const serviceAccount = JSON.parse(
  process.env.FIREBASE_SERVICE_ACCOUNT_JSON
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const messaging = admin.messaging();

/*
 * اختبار إن السيرفر شغال
 */
app.get("/health", (req, res) => {
  res.json({
    success: true,
    message: "Khadem notification backend is running",
  });
});

/*
 * إرسال إشعار رسالة Chat
 */
app.post("/send-chat-notification", async (req, res) => {
  try {
    // 1) التأكد من وجود Firebase ID Token
    const authHeader = req.headers.authorization || "";

    if (!authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        message: "Missing authorization token",
      });
    }

    const idToken = authHeader.substring(7);

    // 2) التحقق من أن المستخدم فعلًا مستخدم Firebase
    const decodedToken = await admin.auth().verifyIdToken(idToken);

    const senderUid = decodedToken.uid;

    // 3) البيانات القادمة من Flutter
    const { chatId, messageId, text } = req.body;

    if (!chatId || !messageId || !text) {
      return res.status(400).json({
        success: false,
        message: "chatId, messageId and text are required",
      });
    }

    // 4) قراءة المحادثة
    const chatRef = db.collection("chats").doc(chatId);
    const chatSnapshot = await chatRef.get();

    if (!chatSnapshot.exists) {
      return res.status(404).json({
        success: false,
        message: "Chat not found",
      });
    }

    const chatData = chatSnapshot.data();

    const participants = chatData.participants || [];

    // 5) التأكد أن الشخص الذي طلب إرسال الإشعار موجود فعلًا في المحادثة
    if (!participants.includes(senderUid)) {
      return res.status(403).json({
        success: false,
        message: "You are not a participant in this chat",
      });
    }

    // 6) تحديد الطرف الآخر
    const receiverUid = participants.find(
      (uid) => uid !== senderUid
    );

    if (!receiverUid) {
      return res.status(400).json({
        success: false,
        message: "Receiver not found",
      });
    }

    // 7) الحصول على اسم المرسل
    const senderSnapshot = await db
      .collection("users")
      .doc(senderUid)
      .get();

    const senderData = senderSnapshot.exists
      ? senderSnapshot.data()
      : {};

    const senderName =
      senderData.name ||
      senderData.displayName ||
      "رسالة جديدة";

    // 8) الحصول على كل FCM Tokens الخاصة بالمستقبل
    const tokensSnapshot = await db
      .collection("users")
      .doc(receiverUid)
      .collection("fcmTokens")
      .get();

    if (tokensSnapshot.empty) {
      return res.json({
        success: true,
        sent: 0,
        message: "Receiver has no FCM tokens",
      });
    }

    let sentCount = 0;
    let failedCount = 0;

    // 9) إرسال الإشعار لكل جهاز
    for (const tokenDoc of tokensSnapshot.docs) {
      const tokenData = tokenDoc.data();
      const token = tokenData.token;

      if (!token) {
        continue;
      }

      try {
        await messaging.send({
          token: token,

          notification: {
            title: senderName,
            body: text,
          },

          data: {
            type: "chat",
            senderId: senderUid,
            receiverId: receiverUid,
            chatId: chatId,
            messageId: messageId,
            senderName: senderName,
          },

          android: {
            notification: {
              channelId: "chat_messages",
              sound: "default",
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

        sentCount++;
      } catch (error) {
        failedCount++;

        console.error(
          "FCM send error:",
          error.message
        );

        // لو الـ token أصبح غير صالح، نحذفه من Firestore
        if (
          error.code ===
            "messaging/registration-token-not-registered" ||
          error.code ===
            "messaging/invalid-registration-token"
        ) {
          await tokenDoc.ref.delete();
        }
      }
    }

    return res.json({
      success: true,
      sent: sentCount,
      failed: failedCount,
    });
  } catch (error) {
    console.error("Notification backend error:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

/*
 * تشغيل السيرفر
 */
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(
    `Khadem notification backend running on port ${PORT}`
  );
});