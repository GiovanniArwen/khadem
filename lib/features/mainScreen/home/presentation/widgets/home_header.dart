import 'package:flutter/material.dart';
import 'package:khadem/core/utils/text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أهلاً بك 👋',
              style: TextStyles.title.copyWith(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'ربنا يبارك خدمتك ✨',
              style: TextStyles.headline.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),

        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            size: 26,
          ),
        ),
      ],
    );
  }
}