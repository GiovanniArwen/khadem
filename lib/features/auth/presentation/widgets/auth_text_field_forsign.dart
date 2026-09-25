import 'package:flutter/material.dart';
import 'package:khadem/core/utils/colors.dart';

class AuthTextFieldS extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  const AuthTextFieldS({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDarkColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            style: const TextStyle(
              color: AppColors.textDarkColor,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: AppColors.hintColor,
                fontSize: 13,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: AppColors.primaryColor,
                      size: 21,
                    )
                  : null,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
              border: _border(AppColors.borderColor),
              enabledBorder: _border(AppColors.borderColor),
              focusedBorder: _border(
                AppColors.primaryColor,
                width: 1.4,
              ),
              errorBorder: _border(AppColors.redColor),
              focusedErrorBorder: _border(
                AppColors.redColor,
                width: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(
    Color color, {
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}