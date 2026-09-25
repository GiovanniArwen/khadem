import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khadem/features/mainScreen/chat/data/models/chat_model.dart';
import 'package:khadem/features/mainScreen/chat/data/models/message_model.dart';

class ChatRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

        // عدد الرسائل غير المقروءة لكل مستخدم
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

    final batch = _firestore.batch();

    // 1. إضافة الرسالة
    batch.set(messageRef, {
      'senderId': currentUid,
      'text': trimmedText,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. تحديث بيانات الشات
    // نزيد unread عند الشخص الآخر فقط
    batch.update(chatRef, {
      'lastMessage': trimmedText,
      'updatedAt': FieldValue.serverTimestamp(),
      'unread.$otherUserId': FieldValue.increment(1),
    });

    await batch.commit();
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