import 'package:flutter/material.dart';
import 'package:khadem/core/constants/app_images.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:svg_flutter/svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
     super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      pushWithReplacement(context, Routes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: SvgPicture.asset(AppImages.logoSvg, width: 250)),
    );
  }
}
