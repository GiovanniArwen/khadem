import 'package:flutter/material.dart';
import 'package:khadem/core/utils/colors.dart';

class AuthCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const AuthCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderColor,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}