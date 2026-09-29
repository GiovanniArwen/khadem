import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khadem/core/constants/app_images.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/features/auth/data/repo/auth_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:svg_flutter/svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Same key must be used by the onboarding screen when it finishes,
  /// e.g. `prefs.setBool(kHasSeenOnboardingKey, true)`.
  static const String kHasSeenOnboardingKey = 'has_seen_onboarding';

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool(kHasSeenOnboardingKey) ?? false;

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user == null) {
      if (!hasSeenOnboarding) {
        pushWithReplacement(context, Routes.onboarding);
      } else {
        pushWithReplacement(context, Routes.login);
      }
      return;
    }

    // المستخدم مسجل دخول أصلًا، يبقى أكيد شاف الـ Onboarding قبل كده.
    // بنثبتها دفاعيًا هنا كمان لو حصل تسجيل دخول من غير ما يعدي عليها.
    if (!hasSeenOnboarding) {
      await prefs.setBool(kHasSeenOnboardingKey, true);
    }

    final result = await AuthRepo.getCurrentUserRoles();

    if (!mounted) return;
    result.fold(
      (error) {
        pushWithReplacement(context, Routes.login);
      },
      (roles) {
        pushWithReplacement(
          context,
          Routes.main,
          extra: {
            'isServant': roles.isServant,
            'isChurchAdmin': roles.isChurchAdmin,
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: SvgPicture.asset(AppImages.logoSvg, width: 250)),
    );
  }
}