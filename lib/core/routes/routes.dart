import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khadem/features/auth/presentation/page/login_screen.dart';
import 'package:khadem/features/auth/presentation/page/signup_screen.dart';
import 'package:khadem/features/intro/splash/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Routes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
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

  static final routes = GoRouter(
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
       GoRoute(path: login, builder: (context, state) => const LoginScreen()),
       GoRoute(path: signup, builder: (context, state) => const SignUpScreen()),
    ],
  );
}
