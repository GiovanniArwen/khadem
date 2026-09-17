import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/features/mainScreen/chat/data/repo/chat_repo.dart';
import 'package:khadem/features/mainScreen/chat/data/repo/user_profile_repo.dart';

import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepo chatRepo;
  final UserProfileRepo userProfileRepo;

  StreamSubscription? _messagesSubscription;

  ChatBloc({required this.chatRepo, required this.userProfileRepo})
    : super(ChatInitial()) {
    on<LoadChatUserEvent>(_loadChatUser);
    on<LoadMessagesEvent>(_loadMessages);
    on<SendMessageEvent>(_sendMessage);

    on<MessagesUpdatedEvent>((event, emit) {
      emit(MessagesLoaded(messages: event.messages));
    });

    on<MessagesErrorEvent>((event, emit) {
      emit(ChatError(message: event.messages));
    });
  }

  // =========================
  // Load User
  // =========================

  Future<void> _loadChatUser(
    LoadChatUserEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatUserLoading());

    try {
      final user = await userProfileRepo.getChatUser(event.userId);

      if (user == null) {
        emit(ChatUserError(message: 'بيانات المستخدم غير موجودة'));
        return;
      }

      emit(ChatUserLoaded(user: user));
    } catch (e) {
      emit(ChatUserError(message: 'حدث خطأ أثناء تحميل بيانات المستخدم'));
    }
  }

  // =========================
  // Load Messages
  // =========================

  Future<void> _loadMessages(
    LoadMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    await _messagesSubscription?.cancel();

    try {
      await chatRepo.createChatIfNotExists(otherUserId: event.otherUserId);

      _messagesSubscription = chatRepo
          .getMessages(otherUserId: event.otherUserId)
          .listen(
            (messages) {
              add(MessagesUpdatedEvent(messages: messages));
            },
            onError: (error) {
              add(MessagesErrorEvent(messages: 'حدث خطأ أثناء تحميل الرسائل'));
            },
          );
    } catch (e) {
      emit(ChatError(message: 'حدث خطأ أثناء فتح المحادثة'));
    }
  }

  // =========================
  // Send Message
  // =========================

  Future<void> _sendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.text.trim();

    if (text.isEmpty) {
      return;
    }

    try {
      emit(MessageSending());

      await chatRepo.sendMessage(otherUserId: event.otherUserId, text: text);

      emit(MessageSent());
    } catch (e) {
      emit(ChatError(message: 'فشل إرسال الرسالة'));
    }
  }

  // =========================
  // Dispose
  // =========================

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    return super.close();
  }
}
