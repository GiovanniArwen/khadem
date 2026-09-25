import 'package:flutter/material.dart';
import 'package:khadem/core/utils/colors.dart';

class ServiceTimeSelector extends StatelessWidget {
  final String? openTime;
  final String? closeTime;
  final VoidCallback onOpenTap;
  final VoidCallback onCloseTap;

  const ServiceTimeSelector({
    super.key,
    required this.openTime,
    required this.closeTime,
    required this.onOpenTap,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مواعيد الخدمة المتاحة (اختياري)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDarkColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _TimeBox(
                label: 'من',
                value: openTime,
                onTap: onOpenTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TimeBox(
                label: 'إلى',
                value: closeTime,
                onTap: onCloseTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _TimeBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.fieldColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              color: AppColors.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              value ?? label,
              style: TextStyle(
                color: value == null
                    ? AppColors.hintColor
                    : AppColors.textDarkColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}