import 'package:flutter/material.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/utils/colors.dart';
import 'package:khadem/features/mainScreen/chat/presentation/widgets/user_avatar.dart';

const _softGrey = Color(0xFFF3F4F8);
const _borderColor = Color(0xFFEEF0F5);

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.whiteColor,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: _borderColor),
  boxShadow: [
    BoxShadow(
      color: AppColors.primaryColor.withOpacity(0.06),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ],
);

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
    final hasUnread = unreadCount > 0;
    final hasMessage = message.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            pushTo(
              context,
              Routes.chat,
              extra: {'uid': uid, 'name': name, 'role': role, 'image': image},
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                UserAvatar(name: name, image: image, size: 64),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الاسم + الوقت
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              color: hasUnread
                                  ? AppColors.primaryColor
                                  : AppColors.greyColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // الدور / المحافظة / التخصص
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (role.isNotEmpty)
                            _InfoChip(
                              label: role,
                              background: AppColors.secondaryColor,
                              foreground: AppColors.primaryColor,
                              bold: true,
                            ),
                          if (governorate != null && governorate!.isNotEmpty)
                            _InfoChip(
                              label: governorate!,
                              icon: Icons.location_on_outlined,
                              background: _softGrey,
                              foreground: AppColors.greyColor,
                            ),
                          if (specialization != null &&
                              specialization!.isNotEmpty)
                            _InfoChip(
                              label: specialization!,
                              background: _softGrey,
                              foreground: AppColors.darkColor,
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // آخر رسالة + عداد الغير مقروء
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              hasMessage ? message : 'ابدأ المحادثة',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.3,
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: hasUnread
                                    ? AppColors.darkColor
                                    : AppColors.greyColor,
                              ),
                            ),
                          ),
                          if (hasUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              constraints: const BoxConstraints(
                                minWidth: 22,
                                minHeight: 22,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.whiteColor,
                                ),
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
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final bool bold;

  const _InfoChip({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// شكل مؤقت بيظهر لحد ما بيانات المستخدم تتحمّل
class ChatTileSkeleton extends StatelessWidget {
  const ChatTileSkeleton({super.key});

  Widget _bar(double width, double height) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: _softGrey,
      borderRadius: BorderRadius.circular(6),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _softGrey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(130, 14),
                const SizedBox(height: 10),
                _bar(80, 12),
                const SizedBox(height: 10),
                _bar(double.infinity, 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}