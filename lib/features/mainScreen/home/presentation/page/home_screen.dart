import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/services/notification_service.dart';
import 'package:khadem/features/mainScreen/servants/data/models/servant_model.dart';
import 'package:khadem/features/mainScreen/servants/presentation/bloc/servant_bloc.dart';
import 'package:khadem/features/mainScreen/servants/presentation/bloc/servant_event.dart';
import 'package:khadem/features/mainScreen/servants/presentation/bloc/servant_states.dart';
import '../widgets/home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.isServant,
    required this.isChurchAdmin,
  });

  final bool isServant;
  final bool isChurchAdmin;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _verseController = PageController();

  final List<Map<String, String>> verses = [
    {
      'verse': '«أَسْتَطِيعُ كُلَّ شَيْءٍ فِي الْمَسِيحِ الَّذِي يُقَوِّينِي»',
      'reference': 'فيلبي 4: 13',
    },
    {
      'verse':
          '«كُلُّ مَا تَصْنَعُونَهُ فَاعْمَلُوهُ مِنَ الْقَلْبِ كَمَا لِلرَّبِّ»',
      'reference': 'كولوسي 3: 23',
    },
    {
      'verse':
          '«كُنْ أَمِينًا إِلَى الْمَوْتِ فَسَأُعْطِيكَ إِكْلِيلَ الْحَيَاةِ»',
      'reference': 'رؤيا 2: 10',
    },
    {
      'verse': '«لَا تَسْتَهِنْ بِمَوْهِبَتِكَ»',
      'reference': '1 تيموثاوس 4: 14',
    },
  ];

  @override
  void initState() {
    super.initState();

    final notifications = NotificationService.instance;

    notifications.attachTapHandler((data) {
      if (!mounted) return;
      pushTo(
        context,
        Routes.chat,
        extra: {
          'uid': (data['senderId'] ?? '').toString(),
          'name': (data['senderName'] ?? '').toString(),
          'role': '',
        },
      );
    });

    notifications.init();
  }

  @override
  void dispose() {
    NotificationService.instance.detachTapHandler();
    _verseController.dispose();
    super.dispose();
  }

  void _goToServants() {
    pushTo(context, Routes.servants);
  }

  void _goToAppointments() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) return;

    pushTo(context, Routes.agenda, extra: uid);
  }

  @override
  @override
  Widget build(BuildContext context) {
    final bool isServant = widget.isServant;
    final bool isChurchAdmin = widget.isChurchAdmin;

    // هل المستخدم مسؤول اجتماع؟
    final bool isAdminOnly = isChurchAdmin && !isServant;

    // هل المستخدم خادم فقط؟
    final bool isServantOnly = isServant && !isChurchAdmin;

    // هل المستخدم خادم + مسؤول اجتماع؟
    final bool isBoth = isServant && isChurchAdmin;

    return BlocProvider(
      // مفيش داعي لتحميل الخدام لو المستخدم خادم فقط.
      create: (context) => ServantBloc()..add(LoadServantsEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),

                const SizedBox(height: 22),

                // =========================================================
                // Encouraging Verses
                // =========================================================
                SizedBox(
                  height: 175,
                  child: PageView.builder(
                    controller: _verseController,
                    itemCount: verses.length,
                    itemBuilder: (context, index) {
                      final verse = verses[index];

                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [Color(0xFF004AAD), Color(0xFF2962FF)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF004AAD).withOpacity(0.18),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.format_quote_rounded,
                              color: Colors.white70,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              verse['verse']!,
                              textAlign: TextAlign.right,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              verse['reference']!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // =========================================================
                // SERVANT ONLY
                // =========================================================
                if (isServantOnly) ...[
                  const SizedBox(height: 25),

                  // مواعيدي
                  _buildMainActionButton(
                    title: 'مواعيدي',
                    icon: Icons.calendar_month_rounded,
                    onTap: _goToAppointments,
                  ),

                  const SizedBox(height: 16),

                  // خدمتك لها تأثير
                  _buildImpactCard(),

                  const SizedBox(height: 14),

                  // قريباً - إعلان التوفر
                  _buildComingSoonCard(),
                ],

                // =========================================================
                // ADMIN ONLY
                // =========================================================
                if (isAdminOnly) ...[
                  const SizedBox(height: 25),

                  _buildInvitationCard(),

                  const SizedBox(height: 30),

                  _buildServantsSection(),
                ],

                // =========================================================
                // SERVANT + ADMIN
                // =========================================================
                if (isBoth) ...[
                  const SizedBox(height: 25),

                  // مواعيدي + دعوة خادم
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactActionButton(
                          title: 'مواعيدي',
                          icon: Icons.calendar_month_rounded,
                          onTap: _goToAppointments,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCompactActionButton(
                          title: 'دعوة خادم',
                          icon: Icons.person_add_alt_1_rounded,
                          onTap: _goToServants,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  _buildServantsSection(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Main Action Button
  // =========================================================
  Widget _buildMainActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF004AAD),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // =========================================================
  // Compact Button
  // =========================================================
  Widget _buildCompactActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF004AAD),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // =========================================================
  // خدمتك لها تأثير
  // =========================================================
  Widget _buildImpactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              color: Color(0xFF004AAD),
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خدمتك لها تأثير',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  'كن مستعدًا لخدمة الآخرين عندما يحتاجون إليك.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // قريباً - إعلان التوفر
  // =========================================================
  Widget _buildComingSoonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E4EA)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E5EB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.grey,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'إعلان التوفر',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'قريبًا',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  'أعلن أنك متاح للخدمة في يوم معين ليعرف الآخرون أنك مستعد.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_left_rounded, color: Colors.grey),
        ],
      ),
    );
  }

  // =========================================================
  // Invitation Card
  // =========================================================
  Widget _buildInvitationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Color(0xFF004AAD),
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ابدأ دعوة الخادم الآن',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  'قم بدعوة خادم أو فريق تسبيح أو دراما لاجتماع كنيستك',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: _goToServants,
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Servants Section
  // =========================================================
  Widget _buildServantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _goToServants,
              child: const Text(
                'مشاهدة الكل',
                style: TextStyle(
                  color: Color(0xFF004AAD),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Text(
              'الخدام',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 10),

        BlocBuilder<ServantBloc, ServantState>(
          builder: (context, state) {
            if (state is ServantLoadingState) {
              return const SizedBox(
                height: 185,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is ServantErrorState) {
              return SizedBox(
                height: 185,
                child: Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            if (state is ServantLoadedState) {
              final servants = state.servants;

              if (servants.isEmpty) {
                return const SizedBox(
                  height: 185,
                  child: Center(
                    child: Text(
                      'لا يوجد خدام حاليًا',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              final displayedServants = servants.take(5).toList();

              return SizedBox(
                height: 185,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayedServants.length,
                  itemBuilder: (context, index) {
                    final servant = displayedServants[index];

                    return _buildServantCard(servant: servant);
                  },
                ),
              );
            }

            return const SizedBox(height: 185);
          },
        ),
      ],
    );
  }

  Widget _buildServantCard({required ServantModel servant}) {
    return GestureDetector(
      onTap: _goToServants,
      child: Container(
        width: 145,
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE7EAF0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEAF1FF),
              ),
              child: servant.image != null && servant.image!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        servant.image!,
                        width: 68,
                        height: 68,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF004AAD),
                            size: 38,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF004AAD),
                      size: 38,
                    ),
            ),

            const SizedBox(height: 10),

            Text(
              servant.name ?? 'بدون اسم',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              servant.specialization ?? 'بدون تخصص',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF004AAD), fontSize: 13),
            ),

            if (servant.governorate != null &&
                servant.governorate!.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                servant.governorate!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }

}
