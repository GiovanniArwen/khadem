import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:khadem/features/mainScreen/chat/data/models/chat_model.dart';
import 'package:khadem/features/mainScreen/chat/data/models/message_model.dart';

class ChatRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _notificationWorkerUrl =
      'https://khadem.jovanyarwen.workers.dev/send-chat-notification';

  String get currentUid {
    final uid = _auth.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    return uid;
  }

  String getChatId(String otherUserId) {
    if (otherUserId.isEmpty) {
      throw Exception('معرف المستخدم الآخر غير موجود');
    }

    if (otherUserId == currentUid) {
      throw Exception('لا يمكن إنشاء محادثة مع نفسك');
    }

    final ids = [currentUid, otherUserId]..sort();

    return '${ids[0]}_${ids[1]}';
  }

  DocumentReference<Map<String, dynamic>> _chatReference(
    String otherUserId,
  ) {
    return _firestore.collection('chats').doc(getChatId(otherUserId));
  }

  CollectionReference<Map<String, dynamic>> _messagesReference(
    String otherUserId,
  ) {
    return _chatReference(otherUserId).collection('messages');
  }

  Future<void> createChatIfNotExists({
    required String otherUserId,
  }) async {
    final chatRef = _chatReference(otherUserId);

    final snapshot = await chatRef.get();

    if (!snapshot.exists) {
      await chatRef.set({
        'participants': [currentUid, otherUserId],
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
        'unread': {
          currentUid: 0,
          otherUserId: 0,
        },
      });
    }
  }

  Stream<List<MessageModel>> getMessages({
    required String otherUserId,
  }) {
    return _messagesReference(otherUserId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => MessageModel.fromJson(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<void> sendMessage({
    required String otherUserId,
    required String text,
  }) async {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) return;

    await createChatIfNotExists(
      otherUserId: otherUserId,
    );

    final chatRef = _chatReference(otherUserId);

    final messageRef = _messagesReference(otherUserId).doc();

    final messageId = messageRef.id;

    final batch = _firestore.batch();

    // 1. إضافة الرسالة
    batch.set(messageRef, {
      'senderId': currentUid,
      'text': trimmedText,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. تحديث بيانات الشات
    batch.update(chatRef, {
      'lastMessage': trimmedText,
      'updatedAt': FieldValue.serverTimestamp(),
      'unread.$otherUserId': FieldValue.increment(1),
    });

    // 3. حفظ الرسالة أولًا في Firestore
    await batch.commit();

    // 4. بعد نجاح حفظ الرسالة، نرسل طلب للـ Worker
    try {
      await _sendChatNotification(
        chatId: chatRef.id,
        messageId: messageId,
        text: trimmedText,
      );
    } catch (error) {
      // مهم:
      // فشل الإشعار لا يعني فشل إرسال الرسالة.
      print('Chat notification error: $error');
    }
  }

  Future<void> _sendChatNotification({
    required String chatId,
    required String messageId,
    required String text,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    // الحصول على Firebase ID Token
    final idToken = await user.getIdToken();

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Firebase ID Token غير موجود');
    }

    final response = await http.post(
      Uri.parse(_notificationWorkerUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'chatId': chatId,
        'messageId': messageId,
        'text': text,
      }),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Notification Worker error '
        '${response.statusCode}: ${response.body}',
      );
    }

    print(
      'Chat notification response: ${response.body}',
    );
  }

  /// تصفير الرسائل غير المقروءة في محادثة معينة
  Future<void> markChatAsRead({
    required String otherUserId,
  }) async {
    final chatRef = _chatReference(otherUserId);

    await chatRef.update({
      'unread.$currentUid': 0,
    });
  }

  Stream<List<ChatModel>> getMyChats() {
    return _firestore
        .collection('chats')
        .where(
          'participants',
          arrayContains: currentUid,
        )
        .orderBy(
          'updatedAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ChatModel.fromJson(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  /// إجمالي كل الرسائل غير المقروءة في جميع المحادثات
  Stream<int> getTotalUnreadCount() {
    return getMyChats().map(
      (chats) {
        int total = 0;

        for (final chat in chats) {
          total += chat.unreadFor(currentUid);
        }

        return total;
      },
    );
  }
}
