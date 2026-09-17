import 'package:khadem/features/mainScreen/chat/data/models/chat_user_model.dart';
import 'package:khadem/features/mainScreen/chat/data/models/message_model.dart';


abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatUserLoading extends ChatState {}

class ChatUserLoaded extends ChatState {
  final ChatUserModel user;

  ChatUserLoaded({
    required this.user,
  });
}

class ChatUserError extends ChatState {
  final String message;

  ChatUserError({
    required this.message,
  });
}

class MessagesLoaded extends ChatState {
  final List<MessageModel> messages;

  MessagesLoaded({
    required this.messages,
  });
}

class ChatError extends ChatState {
  final String message;

  ChatError({
    required this.message,
  });
}

class MessageSending extends ChatState {}

class MessageSent extends ChatState {}