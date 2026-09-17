import 'package:khadem/features/mainScreen/chat/data/models/message_model.dart';

abstract class ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final String otherUserId;

  LoadMessagesEvent({required this.otherUserId});
}

class SendMessageEvent extends ChatEvent {
  final String otherUserId;
  final String text;

  SendMessageEvent({required this.otherUserId, required this.text});
}

class LoadChatUserEvent extends ChatEvent {
  final String userId;

  LoadChatUserEvent({required this.userId});
}

class MessagesUpdatedEvent extends ChatEvent {
final List <MessageModel> messages;
  MessagesUpdatedEvent({required this.messages});
}

class MessagesErrorEvent extends ChatEvent {
  String messages;
  MessagesErrorEvent({required this.messages});
}
