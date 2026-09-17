import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khadem/core/utils/colors.dart';
import 'package:khadem/features/mainScreen/chat/data/models/chat_model.dart';
import 'package:khadem/features/mainScreen/chat/data/models/chat_user_model.dart';
import 'package:khadem/features/mainScreen/chat/data/repo/chat_repo.dart';
import 'package:khadem/features/mainScreen/chat/data/repo/user_profile_repo.dart';
import 'package:khadem/features/mainScreen/chat/presentation/widgets/chat_title.dart';

class ChatMainScreen extends StatefulWidget {
  const ChatMainScreen({super.key});

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  final ChatRepo _chatRepo = ChatRepo();
  final UserProfileRepo _userProfileRepo = UserProfileRepo();
  String _query = '';

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final isToday =
        dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;

    if (!isToday) {
      return '${dateTime.day}/${dateTime.month}';
    }

    int hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    hour = hour % 12;
    if (hour == 0) hour = 12;

    return '$hour:$minute ${isPm ? 'م' : 'ص'}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) {
      return const Scaffold(
        body: Center(child: Text('خطأ: المستخدم غير مسجل الدخول')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('المحادثات'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: TextField(
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: 'ابحث في المحادثات...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<ChatModel>>(
              stream: _chatRepo.getMyChats(),
              builder: (context, snapshot) {
                print('CHAT STREAM STATE: ${snapshot.connectionState}');
                print('CHAT STREAM DATA COUNT: ${snapshot.data?.length}');
                print('CHAT STREAM ERROR: ${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                }

                final chats = snapshot.data ?? [];

                if (chats.isEmpty) {
                  return const Center(child: Text('لا توجد محادثات بعد'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    print(
                      'CHAT #$index participants: ${chat.participants}, lastMessage: ${chat.lastMessage}',
                    );
                    final otherUid = chat.participants.firstWhere(
                      (id) => id != currentUid,
                      orElse: () => '',
                    );
                    print('OTHER UID: $otherUid (currentUid: $currentUid)');

                    if (otherUid.isEmpty) return const SizedBox();

                    return FutureBuilder<ChatUserModel?>(
                      future: () async {
                        try {
                          return _userProfileRepo.getChatUser(otherUid);
                        } catch (e, st) {
                          print('GET CHAT USER ERROR for $otherUid: $e');
                          print(st);
                          return null;
                        }
                      }(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) return const SizedBox();

                        final user = userSnapshot.data!;

                        if (_query.isNotEmpty && !user.name.contains(_query)) {
                          return const SizedBox();
                        }

                        return ChatTile(
                          uid: otherUid,
                          name: user.name,
                          role: user.roleText,
                          message: chat.lastMessage,
                          time: _formatTime(chat.updatedAt),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
