import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.size = 120, this.message});

  final double size;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Lottie.asset(
            'assets/images/loading.json',
            width: size,
            height: size,
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
            onLoaded: (composition) {
              debugPrint('Lottie Loaded Successfully');
            },
          ),
        ),

        if (message != null) ...[const SizedBox(height: 10), Text(message!)],
      ],
    );
  }
}
