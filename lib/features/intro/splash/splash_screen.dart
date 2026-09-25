import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khadem/core/constants/app_images.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/features/auth/data/repo/auth_repo.dart';
import 'package:svg_flutter/svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  @override
  // void initState() {
  //   super.initState();
  //   Future.delayed(const Duration(seconds: 1), () {
  //     if (!mounted) return;
  //     pushWithReplacement(context, Routes.login);
  //   });
  // }
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 1));

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user == null) {
      pushWithReplacement(
        context,
        Routes.onboarding,
      ); // بدل Routes.login مباشرة
      return;
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
