import 'package:flutter/material.dart';
import 'package:khadem/core/utils/colors.dart';

class SpecializationSelector extends StatelessWidget {
  final String? value;
  final List<Map<String, dynamic>> specializations;
  final ValueChanged<String> onChanged;

  const SpecializationSelector({
    super.key,
    required this.value,
    required this.specializations,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: value,
      validator: (_) {
        if (value == null || value!.isEmpty) {
          return 'اختر التخصص';
        }

        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  'التخصص',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDarkColor,
                  ),
                ),
                Text(
                  ' *',
                  style: TextStyle(color: AppColors.redColor, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: specializations.map((item) {
                final name = item['name'] as String;
                final icon = item['icon'] as IconData;
                final isSelected = value == name;

                return GestureDetector(
                  onTap: () {
                    onChanged(name);
                    field.didChange(name);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.fieldColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 18,
                          color: isSelected
                              ? AppColors.whiteColor
                              : AppColors.textGreyColor,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          name,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.whiteColor
                                : AppColors.textDarkColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    color: AppColors.redColor,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
