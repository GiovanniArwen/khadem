import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:khadem/features/main_screen/chat/data/models/chat_model.dart';
import 'package:khadem/features/main_screen/chat/data/models/message_model.dart';
import 'package:khadem/features/main_screen/chat/data/models/message_reaction_model.dart';

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

  DocumentReference<Map<String, dynamic>> _chatReference(String otherUserId) {
    return _firestore.collection('chats').doc(getChatId(otherUserId));
  }

  CollectionReference<Map<String, dynamic>> _messagesReference(
    String otherUserId,
  ) {
    return _chatReference(otherUserId).collection('messages');
  }

  Future<void> createChatIfNotExists({required String otherUserId}) async {
    final chatRef = _chatReference(otherUserId);

    final snapshot = await chatRef.get();

    if (!snapshot.exists) {
      await chatRef.set({
        'participants': [currentUid, otherUserId],
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
        'unread': {currentUid: 0, otherUserId: 0},
      });
    }
  }

  Stream<List<MessageModel>> getMessages({required String otherUserId}) {
    return _messagesReference(otherUserId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> sendMessage({
    required String otherUserId,
    required String text,
  }) async {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) return;

    await createChatIfNotExists(otherUserId: otherUserId);

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

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Notification Worker error '
        '${response.statusCode}: ${response.body}',
      );
    }
    //redeploy 2
    print('Chat notification response: ${response.body}');
  }

  /// تصفير الرسائل غير المقروءة في محادثة معينة
  Future<void> markChatAsRead({required String otherUserId}) async {
    final chatRef = _chatReference(otherUserId);

    await chatRef.update({'unread.$currentUid': 0});
  }

  Stream<List<ChatModel>> getMyChats() {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatModel.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  /// إجمالي كل الرسائل غير المقروءة في جميع المحادثات
  Stream<int> getTotalUnreadCount() {
    return getMyChats().map((chats) {
      int total = 0;

      for (final chat in chats) {
        total += chat.unreadFor(currentUid);
      }

      return total;
    });
  }

  CollectionReference<Map<String, dynamic>> _reactionsReference({
    required String otherUserId,
    required String messageId,
  }) {
    return _messagesReference(
      otherUserId,
    ).doc(messageId).collection('reactions');
  }

  Stream<List<MessageReactionModel>> getMessageReactions({
    required String otherUserId,
    required String messageId,
  }) {
    return _reactionsReference(
      otherUserId: otherUserId,
      messageId: messageId,
    ).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => MessageReactionModel.fromJson(doc.id, doc.data()))
          .where((reaction) => reaction.emoji.isNotEmpty)
          .toList(),
    );
  }

  Future<void> toggleMessageReaction({
    required String otherUserId,
    required String messageId,
    required String emoji,
  }) async {
    const allowedEmojis = ['👍', '❤️', '😂', '🙏', '😮'];

    if (!allowedEmojis.contains(emoji)) {
      throw ArgumentError('Reaction غير مسموح');
    }

    final reactionRef = _reactionsReference(
      otherUserId: otherUserId,
      messageId: messageId,
    ).doc(currentUid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reactionRef);

      final existingEmoji = snapshot.data()?['emoji'];

      if (snapshot.exists && existingEmoji == emoji) {
        transaction.delete(reactionRef);
      } else {
        transaction.set(reactionRef, {
          'emoji': emoji,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> deleteMessageForEveryone({
    required String otherUserId,
    required String messageId,
  }) async {
    final messagesRef = _messagesReference(otherUserId);
    final messageRef = messagesRef.doc(messageId);
    final chatRef = _chatReference(otherUserId);

    // قراءة أحدث رسالة قبل بدء الـ transaction
    final latestSnapshot = await messagesRef
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    final isLatestMessage =
        latestSnapshot.docs.isNotEmpty &&
        latestSnapshot.docs.first.id == messageId;

    await _firestore.runTransaction((transaction) async {
      final messageSnapshot = await transaction.get(messageRef);

      if (!messageSnapshot.exists) {
        throw Exception('الرسالة غير موجودة');
      }

      final data = messageSnapshot.data()!;
      final senderId = (data['senderId'] ?? '').toString();

      if (senderId != currentUid) {
        throw Exception('يمكنك حذف رسائلك فقط');
      }
      final timestamp = data['createdAt'];

      if (timestamp is! Timestamp) {
        throw Exception('تعذر التحقق من وقت إرسال الرسالة');
      }

      final sentAt = timestamp.toDate();
      final now = DateTime.now();

      if (now.isBefore(sentAt) ||
          now.difference(sentAt) > const Duration(hours: 1)) {
        throw Exception('انتهت مهلة حذف الرسالة');
      }
      if (data['isDeleted'] == true) {
        return;
      }

      transaction.update(messageRef, {
        'text': 'تم حذف هذه الرسالة',
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });

      if (isLatestMessage) {
        transaction.update(chatRef, {
          'lastMessage': 'تم حذف هذه الرسالة',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
