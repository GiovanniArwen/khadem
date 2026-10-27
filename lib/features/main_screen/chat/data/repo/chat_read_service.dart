import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// بيصفّر عداد الرسائل غير المقروءة بتاع المستخدم الحالي في محادثة معينة.
///
/// العداد متخزن في chats/{chatId}.unread.{uid}
/// والزيادة بتحصل من الـ Cloud Function (index.js) لما رسالة جديدة توصل.
///
/// حطه في: lib/features/mainScreen/chat/data/repo/chat_read_service.dart
class ChatReadService {
  ChatReadService._();
  static final ChatReadService instance = ChatReadService._();

  final CollectionReference<Map<String, dynamic>> _chats = FirebaseFirestore
      .instance
      .collection('chats');

  // "myUid|otherUid" -> chatId (بعد ما نعرفه مرة مبنسألش تاني)
  final Map<String, String> _chatIds = {};

  Future<void> markAsRead(String otherUid) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null || otherUid.isEmpty) return;

    try {
      final chatId = await _resolveChatId(myUid, otherUid);
      if (chatId == null) return;

      await _chats.doc(chatId).update({'unread.$myUid': 0});
    } catch (e) {
      debugPrint('markAsRead error: $e');
    }
  }

  Future<String?> _resolveChatId(String myUid, String otherUid) async {
    final key = '$myUid|$otherUid';

    final cached = _chatIds[key];
    if (cached != null) return cached;

    // 1) الشكل الشائع للـ id: الـ uids مترتبين ومتوصلين بـ _
    final ids = [myUid, otherUid]..sort();
    final guessedId = ids.join('_');

    try {
      final doc = await _chats.doc(guessedId).get();
      if (doc.exists) {
        _chatIds[key] = guessedId;
        return guessedId;
      }
    } on FirebaseException catch (_) {
      // ممكن يطلع permission-denied لو الـ id ده مش موجود، نكمّل للخطوة 2
    }

    // 2) لو الـ id مختلف عندك: دوّر بالـ participants
    final snap = await _chats.where('participants', arrayContains: myUid).get();

    for (final doc in snap.docs) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      if (participants.contains(otherUid)) {
        _chatIds[key] = doc.id;
        return doc.id;
      }
    }

    return null;
  }
}