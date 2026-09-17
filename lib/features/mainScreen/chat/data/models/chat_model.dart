import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime? updatedAt;

  ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    this.updatedAt,
  });

  factory ChatModel.fromJson(String id, Map<String, dynamic> json) {
    final timestamp = json['updatedAt'];

    return ChatModel(
      id: id,
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage'] ?? '',
      updatedAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}
