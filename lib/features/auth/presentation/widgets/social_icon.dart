import 'package:flutter/material.dart';

class SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const SocialIcon({
    super.key,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 30),
    );
  }
}
