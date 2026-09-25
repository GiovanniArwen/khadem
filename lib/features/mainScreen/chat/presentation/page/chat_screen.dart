import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/services/notification_service.dart';
import 'package:khadem/core/utils/colors.dart';
import 'package:khadem/features/mainScreen/chat/data/models/message_model.dart';
import 'package:khadem/features/mainScreen/chat/data/repo/chat_read_service.dart';
import 'package:khadem/features/mainScreen/chat/presentation/bloc/chat_bloc.dart';
import 'package:khadem/features/mainScreen/chat/presentation/bloc/chat_event.dart';
import 'package:khadem/features/mainScreen/chat/presentation/bloc/chat_state.dart';
import 'package:khadem/features/mainScreen/chat/presentation/widgets/date_separator.dart';
import 'package:khadem/features/mainScreen/chat/presentation/widgets/message_bubble.dart';
import 'package:khadem/features/mainScreen/chat/presentation/widgets/message_input.dart';
import 'package:khadem/features/mainScreen/chat/presentation/widgets/user_avatar.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String role;
  final String uid;

  const ChatScreen({
    super.key,
    required this.name,
    required this.role,
    required this.uid,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // عشان منظهرش إشعار لرسالة جاية من الشخص اللي محادثته مفتوحة
    NotificationService.instance.activeChatUid = widget.uid;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final bloc = context.read<ChatBloc>();

      bloc.add(LoadChatUserEvent(userId: widget.uid));

      bloc.add(LoadMessagesEvent(otherUserId: widget.uid));

      // فتحت المحادثة = كل الرسايل اتقرت
      ChatReadService.instance.markAsRead(widget.uid);
    });
  }

  @override
  void dispose() {
    if (NotificationService.instance.activeChatUid == widget.uid) {
      NotificationService.instance.activeChatUid = null;
    }

    // خروج من المحادثة: نصفّر العداد تاني (لو رسالة وصلت وأنا جواها)
    ChatReadService.instance.markAsRead(widget.uid);

    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// لو أحدث رسالة جاية من الطرف التاني وأنا فاتح المحادثة، نصفّر العداد
  void _markReadIfNeeded(BuildContext context, List<MessageModel> messages) {
    if (messages.isEmpty) return;

    final newest = messages.reduce((a, b) {
      final da = a.createdAt ?? DateTime.now();
      final db = b.createdAt ?? DateTime.now();
      return da.isAfter(db) ? a : b;
    });

    final currentUid = context.read<ChatBloc>().chatRepo.currentUid;

    if (newest.senderId != currentUid) {
      ChatReadService.instance.markAsRead(widget.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),

      appBar: AppBar(
        titleSpacing: 0,

        title: BlocBuilder<ChatBloc, ChatState>(
          buildWhen: (previous, current) => current is ChatUserLoaded,

          builder: (context, state) {
            String name = widget.name;
            String role = widget.role;
            String? image;
            String governorate = '';
            String specialization = '';

            if (state is ChatUserLoaded) {
              final user = state.user;

              name = user.name;
              role = user.roleText;
              image = user.image;
              governorate = user.governorate;
              specialization = user.specialization;
            }

            final subtitle = _buildSubtitle(
              role: role,
              governorate: governorate,
              specialization: specialization,
            );

            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (state is ChatUserLoaded && state.user.servant != null) {
                      pushTo(
                        context,
                        Routes.servantDetails,
                        extra: state.user.servant,
                      );
                    }
                  },
                  child: UserAvatar(
                    name: name,
                    image: image,
                    size: 46,
                    ringColor: AppColors.whiteColor.withOpacity(0.85),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColor,
                        ),
                      ),

                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listenWhen: (previous, current) =>
                  current is MessagesLoaded || current is ChatError,
              listener: (context, state) {
                if (state is MessagesLoaded) {
                  _scrollToBottom();
                  _markReadIfNeeded(context, state.messages);
                }

                if (state is ChatError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },

              buildWhen: (previous, current) =>
                  current is ChatLoading ||
                  current is MessagesLoaded ||
                  current is ChatError,

              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (state is MessagesLoaded) {
                  final messages = state.messages;

                  if (messages.isEmpty) {
                    return _EmptyChat(name: widget.name);
                  }

                  final currentUid = context
                      .read<ChatBloc>()
                      .chatRepo
                      .currentUid;

                  return ListView.builder(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final MessageModel message = messages[index];

                      final date = message.createdAt ?? DateTime.now();

                      // الرسالة السابقة في الترتيب الطبيعي:
                      // الأقدم → الأحدث
                      final previousDate = index > 0
                          ? (messages[index - 1].createdAt ?? DateTime.now())
                          : null;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (ChatDateUtils.startsNewDay(date, previousDate))
                            DateSeparator(date: date),

                          MessageBubble(
                            message: message.text,
                            time: ChatDateUtils.time(date),
                            isMe: message.senderId == currentUid,
                          ),
                        ],
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),

          MessageInput(otherUserId: widget.uid),
        ],
      ),
    );
  }

  String _buildSubtitle({
    required String role,
    required String governorate,
    required String specialization,
  }) {
    final parts = <String>[];

    if (governorate.isNotEmpty) {
      parts.add(governorate);
    }

    if (specialization.isNotEmpty) {
      parts.add(specialization);
    }

    if (parts.isEmpty) {
      return role;
    }

    return '$role • ${parts.join(' • ')}';
  }
}

class _EmptyChat extends StatelessWidget {
  final String name;

  const _EmptyChat({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatar(name: name, size: 84),
            const SizedBox(height: 16),
            Text(
              'ابدأ المحادثة مع $name',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'ابعت أول رسالة وهتظهر هنا',
              style: TextStyle(fontSize: 13.5, color: AppColors.greyColor),
            ),
          ],
        ),
      ),
    );
  }
}
