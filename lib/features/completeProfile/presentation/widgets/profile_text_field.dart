import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khadem/core/utils/colors.dart';

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final bool isRequired;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const ProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.isRequired = true,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  OutlineInputBorder _fieldBorder(
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDarkColor,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.redColor,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            maxLines: maxLines,
            maxLength: maxLength,
            style: const TextStyle(
              color: AppColors.textDarkColor,
            ),
            decoration: InputDecoration(
              hintText: hint,
              counterText: '',
              hintStyle: const TextStyle(
                color: AppColors.hintColor,
                fontSize: 13,
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.primaryColor,
                size: 21,
              ),
              filled: true,
              fillColor: AppColors.fieldColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: _fieldBorder(Colors.transparent),
              enabledBorder: _fieldBorder(Colors.transparent),
              focusedBorder: _fieldBorder(
                AppColors.primaryColor,
                width: 1.4,
              ),
              errorBorder: _fieldBorder(AppColors.redColor),
              focusedErrorBorder: _fieldBorder(
                AppColors.redColor,
                width: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}