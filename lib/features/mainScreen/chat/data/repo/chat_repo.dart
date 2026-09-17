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

    await messageRef.set({
      'senderId': currentUid,
      'text': trimmedText,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await chatRef.update({
      'lastMessage': trimmedText,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
}
