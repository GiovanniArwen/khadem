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
  final TextEditingController _searchController = TextEditingController();

  // الـ stream بيتعمل مرة واحدة، عشان ميتعملش subscribe جديد مع كل حرف في البحث
  late final Stream<List<ChatModel>> _chatsStream = _chatRepo.getMyChats();

  // كاش لبيانات المستخدمين عشان منحملهمش تاني مع كل rebuild
  final Map<String, Future<ChatUserModel?>> _userFutures = {};
  final Map<String, ChatUserModel> _users = {};

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<ChatUserModel?> _loadUser(String uid) async {
    try {
      final user = await _userProfileRepo.getChatUser(uid);
      if (user != null) {
        _users[uid] = user;
      } else {
        _userFutures.remove(uid); // نحاول تاني في المرة الجاية
      }
      return user;
    } catch (e, st) {
      debugPrint('GET CHAT USER ERROR for $uid: $e');
      debugPrint('$st');
      _userFutures.remove(uid);
      return null;
    }
  }

  Future<ChatUserModel?> _userFuture(String uid) =>
      _userFutures.putIfAbsent(uid, () => _loadUser(uid));

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

  Widget _buildSearchField() {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value.trim()),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'ابحث في المحادثات...',
          hintStyle: const TextStyle(color: AppColors.greyColor, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFF3F4F8),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primaryColor,
          ),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.greyColor,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
          border: border(Colors.transparent, 0),
          enabledBorder: border(Colors.transparent, 0),
          focusedBorder: border(AppColors.primaryColor, 1.2),
        ),
      ),
    );
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
          _buildSearchField(),
          Expanded(
            child: StreamBuilder<List<ChatModel>>(
              stream: _chatsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _StateMessage(
                    icon: Icons.error_outline_rounded,
                    title: 'حدث خطأ',
                    subtitle: '${snapshot.error}',
                  );
                }

                final chats = snapshot.data ?? [];

                if (chats.isEmpty) {
                  return const _StateMessage(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'لا توجد محادثات بعد',
                    subtitle: 'ابدأ محادثة جديدة وهتظهر هنا',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final otherUid = chat.participants.firstWhere(
                      (id) => id != currentUid,
                      orElse: () => '',
                    );

                    if (otherUid.isEmpty) return const SizedBox.shrink();

                    return FutureBuilder<ChatUserModel?>(
                      future: _userFuture(otherUid),
                      initialData: _users[otherUid],
                      builder: (context, userSnapshot) {
                        final user = userSnapshot.data;

                        if (user == null) {
                          final loading =
                              userSnapshot.connectionState !=
                              ConnectionState.done;
                          return loading && _query.isEmpty
                              ? const ChatTileSkeleton()
                              : const SizedBox.shrink();
                        }

                        if (_query.isNotEmpty && !user.name.contains(_query)) {
                          return const SizedBox.shrink();
                        }

                        return ChatTile(
                          uid: otherUid,
                          name: user.name,
                          role: user.roleText,
                          image: user.image,
                          governorate: user.governorate,
                          specialization: user.specialization,
                          unreadCount: chat.unreadFor(currentUid),
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

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _StateMessage({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: AppColors.secondaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.darkColor,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: AppColors.greyColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
