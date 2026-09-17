import 'package:flutter/material.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/utils/colors.dart';

class ChatTile extends StatelessWidget {
  final String uid;
  final String name;
  final String role;
  final String message;
  final String time;
  final int unreadCount;
  final String? image;
  final String? governorate;
  final String? specialization;

  const ChatTile({
    super.key,
    required this.uid,
    required this.name,
    required this.role,
    required this.message,
    required this.time,
    this.unreadCount = 0,
    this.image,
    this.governorate,
    this.specialization,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),

      onTap: () {
        pushTo(
          context,
          Routes.chat,
          extra: {'uid': uid, 'name': name, 'role': role},
        );
      },

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.secondaryColor,
              backgroundImage: image != null && image!.isNotEmpty
                  ? NetworkImage(image!)
                  : null,
              child: image == null || image!.isEmpty
                  ? const Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryColor,
                    )
                  : null,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkColor,
                          ),
                        ),
                      ),

                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: unreadCount > 0
                              ? AppColors.primaryColor
                              : AppColors.greyColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.greyColor,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      if (governorate != null && governorate!.isNotEmpty)
                        Text(
                          '📍 $governorate',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.greyColor,
                          ),
                        ),

                      if (specialization != null &&
                          specialization!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          specialization!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
