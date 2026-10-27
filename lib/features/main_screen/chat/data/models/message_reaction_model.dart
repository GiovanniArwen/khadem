
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageReactionModel {
  final String userId;
  final String emoji;
  final DateTime? updatedAt;

  const MessageReactionModel({
    required this.userId,
    required this.emoji,
    this.updatedAt,
  });

  factory MessageReactionModel.fromJson(
    String userId,
    Map<String, dynamic> json,
  ) {
    final timestamp = json['updatedAt'];

    return MessageReactionModel(
      userId: userId,
      emoji: json['emoji'] as String? ?? '',
      updatedAt: timestamp is Timestamp
          ? timestamp.toDate()
          : null,
    );
  }
}
