import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime? createdAt;
  final bool isDeleted;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.createdAt,
    this.isDeleted = false,
  });

  factory MessageModel.fromJson(String id, Map<String, dynamic> json) {
    final timestamp = json['createdAt'];

    return MessageModel(
      id: id,
      senderId: (json['senderId'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
      isDeleted: json['isDeleted'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'isDeleted': isDeleted,
    };
  }
}
