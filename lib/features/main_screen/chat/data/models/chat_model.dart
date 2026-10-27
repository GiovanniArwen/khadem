import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime? updatedAt;

  /// عدد الرسائل غير المقروءة لكل مستخدم: { uid: count }
  final Map<String, int> unread;

  ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    this.updatedAt,
    this.unread = const {},
  });

  /// عدد الرسائل اللي [uid] لسه مقراهاش في المحادثة دي
  int unreadFor(String uid) => unread[uid] ?? 0;

  factory ChatModel.fromJson(String id, Map<String, dynamic> json) {
    final timestamp = json['updatedAt'];

    final rawUnread = json['unread'];
    final unread = <String, int>{};
    if (rawUnread is Map) {
      rawUnread.forEach((key, value) {
        if (value is num) unread[key.toString()] = value.toInt();
      });
    }

    return ChatModel(
      id: id,
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage'] ?? '',
      updatedAt: timestamp is Timestamp ? timestamp.toDate() : null,
      unread: unread,
    );
  }
}
