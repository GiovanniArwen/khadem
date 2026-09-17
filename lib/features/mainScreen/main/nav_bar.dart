import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:khadem/core/utils/colors.dart';
import 'package:khadem/core/utils/text_styles.dart';
import 'package:khadem/features/mainScreen/agenda/data/repo/agenda_repo.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/pages/agenda_screen.dart';
import 'package:khadem/features/mainScreen/chat/presentation/page/chat_main_screen.dart';
import 'package:khadem/features/mainScreen/home/presentation/page/home_screen.dart';
import 'package:khadem/features/mainScreen/profile/page/profile_screen.dart';
import 'package:khadem/features/mainScreen/servants/presentation/page/servant_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({
    super.key,
    required this.isServant,
    required this.isChurchAdmin,
    required this.uid,
  });
  final bool isServant;
  final bool isChurchAdmin;
  final String uid;

  @override
  State<MainAppScreen> createState() => _MainPageState();
}

class _MainPageState extends State<MainAppScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    print('================ MAIN APP ================');
    print('MAIN UID: "${widget.uid}"');
    print('===========================================');

    print('================ MAIN APP ================');
    print('MAIN UID: "${widget.uid}"');
    print('isServant: ${widget.isServant}');
    print('isChurchAdmin: ${widget.isChurchAdmin}');
    print('===========================================');

    _pages = [
      // 0 - Home
      HomeScreen(
        isServant: widget.isServant,
        isChurchAdmin: widget.isChurchAdmin,
      ),

      // 1 - Agenda for servants
      if (widget.isServant)
        BlocProvider(
          create: (context) => AgendaBloc(agendaRepo: AgendaRepo()),
          child: AgendaScreen(uid: widget.uid),
        )
      else
        const ServantsScreen(),

      // 2 - Servants for church admins
      if (widget.isChurchAdmin && widget.isServant) const ServantsScreen(),

      // 3 - Chat
      const ChatMainScreen(),

      // 4 - Account
      const AccountScreen(),
    ];
  }

  List<GButton> _buildTabs() {
    return [
      // 0
      const GButton(iconSize: 24, icon: Icons.home, text: 'الرئيسية'),

      // 1
      if (widget.isServant)
        const GButton(iconSize: 24, icon: Icons.calendar_month, text: 'النوتة')
      else
        const GButton(
          iconSize: 24,
          icon: Icons.people_alt_rounded,
          text: 'الخدام',
        ),

      // 2
      if (widget.isChurchAdmin && widget.isServant)
        const GButton(
          iconSize: 24,
          icon: Icons.people_alt_rounded,
          text: 'الخدام',
        ),

      // 3
      const GButton(iconSize: 24, icon: Icons.chat, text: 'المحادثات'),

      // 4
      const GButton(iconSize: 24, icon: Icons.person, text: 'الحساب'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.2)),
          ],
        ),
        child: GNav(
          curve: Curves.easeOutExpo,
          rippleColor: Colors.grey,
          hoverColor: Colors.grey,
          haptic: true,
          tabBorderRadius: 20,

          // قلل المسافة بين الـ tabs
          gap: 3,

          activeColor: Colors.white,

          // كان 20 أفقي، خليه 8
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),

          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: AppColors.primaryColor,

          textStyle: TextStyles.body.copyWith(color: AppColors.whiteColor),

          tabs: _buildTabs(),

          selectedIndex: _selectedIndex,

          onTabChange: (value) {
            setState(() {
              _selectedIndex = value;
            });
          },
        ),
      ),
    );
  }
}
