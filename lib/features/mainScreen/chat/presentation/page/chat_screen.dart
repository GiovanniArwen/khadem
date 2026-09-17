import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/utils/colors.dart';
import 'package:khadem/features/mainScreen/chat/data/models/message_model.dart';
import 'package:khadem/features/mainScreen/chat/presentation/bloc/chat_bloc.dart';
import 'package:khadem/features/mainScreen/chat/presentation/bloc/chat_event.dart';
import 'package:khadem/features/mainScreen/chat/presentation/bloc/chat_state.dart';
import 'package:khadem/features/mainScreen/chat/presentation/widgets/message_bubble.dart';
import 'package:khadem/features/mainScreen/chat/presentation/widgets/message_input.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final bloc = context.read<ChatBloc>();

      bloc.add(LoadChatUserEvent(userId: widget.uid));

      bloc.add(LoadMessagesEvent(otherUserId: widget.uid));
    });
  }

  @override
  void dispose() {
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

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    int hour = dateTime.hour;

    final minute = dateTime.minute.toString().padLeft(2, '0');

    final isPm = hour >= 12;

    hour = hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '$hour:$minute ${isPm ? 'م' : 'ص'}';
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
                  child: CircleAvatar(
                    radius: 21,
                    backgroundColor: AppColors.secondaryColor,
                    backgroundImage: image != null && image.isNotEmpty
                        ? NetworkImage(image)
                        : null,
                    child: image == null || image.isEmpty
                        ? const Icon(
                            Icons.person_rounded,
                            color: AppColors.primaryColor,
                            size: 24,
                          )
                        : null,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColor,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        _buildSubtitle(
                          role: role,
                          governorate: governorate,
                          specialization: specialization,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.secondaryColor,
                        ),
                      ),
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
                    return const Center(
                      child: Text(
                        'ابدأ المحادثة 👋',
                        style: TextStyle(color: AppColors.greyColor),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final MessageModel message = messages[index];

                      final isMe =
                          message.senderId ==
                          context.read<ChatBloc>().chatRepo.currentUid;

                      return MessageBubble(
                        message: message.text,
                        time: _formatTime(message.createdAt),
                        isMe: isMe,
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
