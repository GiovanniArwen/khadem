import 'package:flutter/material.dart';
import 'package:khadem/core/utils/colors.dart';

class GovernorateDropdown extends StatelessWidget {
  final String? value;
  final List<String> governorates;
  final ValueChanged<String?> onChanged;

  const GovernorateDropdown({
    super.key,
    required this.value,
    required this.governorates,
    required this.onChanged,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'المحافظة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDarkColor,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                color: AppColors.redColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primaryColor,
          ),
          hint: const Text(
            'اختر المحافظة',
            style: TextStyle(
              color: AppColors.hintColor,
              fontSize: 13,
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.location_on_outlined,
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
          items: governorates.map((governorate) {
            return DropdownMenuItem<String>(
              value: governorate,
              child: Text(governorate),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'اختر المحافظة';
            }

            return null;
          },
        ),
      ],
    );
  }
}