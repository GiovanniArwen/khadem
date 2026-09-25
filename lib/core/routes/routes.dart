import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:khadem/features/auth/presentation/page/verify_email.dart';
import 'package:khadem/features/completeProfile/presentation/bloc/complete_profile_bloc.dart';
import 'package:khadem/features/completeProfile/presentation/page/complete_profile_screen.dart';
import 'package:khadem/features/auth/presentation/page/login_screen.dart';
import 'package:khadem/features/auth/presentation/page/signup_screen.dart';
import 'package:khadem/features/intro/onboarding/onboarding_screen.dart';
import 'package:khadem/features/mainScreen/agenda/data/repo/agenda_repo.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/pages/agenda_screen.dart';
import 'package:khadem/features/mainScreen/chat/data/repo/chat_repo.dart';
import 'package:khadem/features/mainScreen/chat/data/repo/user_profile_repo.dart';
import 'package:khadem/features/mainScreen/chat/presentation/bloc/chat_bloc.dart';
import 'package:khadem/features/mainScreen/chat/presentation/page/chat_screen.dart';
import 'package:khadem/features/intro/splash/splash_screen.dart';
import 'package:khadem/features/mainScreen/main/nav_bar.dart';
import 'package:khadem/features/mainScreen/profile/page/profile_screen.dart';
import 'package:khadem/features/mainScreen/servants/data/models/servant_model.dart';
import 'package:khadem/features/mainScreen/servants/presentation/page/servant_screen.dart';
import 'package:khadem/features/mainScreen/servants/presentation/widgets/servant_details_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Routes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login_screen';
  static const String signup = '/signup_screen';
  static const String doctorRegistration = '/doctorRegistration';
  static const String mainPatient = '/mainPatient';
  static const String specializationSearch = '/specializationSearch';
  static const String homeSearch = '/homeSearch';
  static const String doctorProfile = '/doctorProfile';
  static const String bookingScreen = '/bookingScreen';
  static const String settings = '/settings';
  static const String home = '/home_screen';
  static const String main = '/nav_bar';
  static const String chat = '/chat_screen';
  static const String completeProfile = '/complete_profile_screen';
  static const String profile = '/profile_screen';
  static const String servants = '/servant_screen';
  static const String servantDetails = '/servant_details_screen';
  // static const String preview = '/preview_screen';
  static const String agenda = '/agenda_screen';
  static const String verifyEmail = '/verify_email';
  static const String onboarding = '/onboarding_screen';

  static final routes = GoRouter(
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(path: splash, builder: (context, state) => SplashScreen()),
      GoRoute(
        path: chat,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (_) => ChatBloc(
              chatRepo: ChatRepo(),
              userProfileRepo: UserProfileRepo(),
            ),
            child: ChatScreen(
              uid: data['uid'] as String,
              name: data['name'] as String,
              role: data['role'] as String,
            ),
          );
        },
      ),
      // GoRoute(path: welcome, builder: (context, state) => WelcomeScreen()),
      GoRoute(
        path: login,
        builder: (context, state) =>
            BlocProvider(create: (_) => AuthBloc(), child: LoginScreen()),
      ),
      GoRoute(
        path: signup,
        builder: (context, state) =>
            BlocProvider(create: (_) => AuthBloc(), child: SignUpScreen()),
      ),
      GoRoute(
        path: main,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          final firebaseUser = FirebaseAuth.instance.currentUser;

          final uid = firebaseUser?.uid ?? '';

          final isServant = extra?['isServant'] as bool? ?? false;
          final isChurchAdmin = extra?['isChurchAdmin'] as bool? ?? false;

          print('================ ROUTE ================');
          print('ROUTE UID: "$uid"');
          print('ROUTE isServant: $isServant');
          print('ROUTE isChurchAdmin: $isChurchAdmin');
          print('========================================');

          return MainAppScreen(
            uid: uid,
            isServant: isServant,
            isChurchAdmin: isChurchAdmin,
          );
        },
      ),
      GoRoute(
        path: servantDetails,
        builder: (context, state) {
          final servant = state.extra as ServantModel;

          return ServantDetailsScreen(servant: servant);
        },
      ),
      GoRoute(
        path: verifyEmail,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return VerifyEmailScreen(
            isServant: data['isServant'] as bool ?? false,
            isChurchAdmin: data['isChurchAdmin'] as bool ?? false,
            uid: data['uid'] as String ?? '',
            email: data['email'] as String ?? '',
          );
        },
      ),
      GoRoute(
        path: agenda,
        builder: (context, state) {
          final uid = state.extra as String;

          return BlocProvider(
            create: (_) => AgendaBloc(agendaRepo: AgendaRepo()),
            child: AgendaScreen(uid: uid),
          );
        },
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) {
          //  final roles = state.extra as Map<String, bool>?;
          return AccountScreen();
        },
      ),
      GoRoute(
        path: servants,
        builder: (context, state) {
          final roles = state.extra as Map<String, bool>?;
          return ServantsScreen();
        },
      ),
      GoRoute(
        path: completeProfile,
        builder: (context, state) {
          final data = state.extra as Map<String, bool>?;
          return BlocProvider(
            create: (_) => CompleteProfileBloc(),
            child: CompleteProfileScreen(
              isServant: data?['isServant'] ?? false,
              isChurchAdmin: data?['isChurchAdmin'] ?? false,
            ),
          );
        },
      ),
    ],
  );
}
