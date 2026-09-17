
import 'package:flutter/material.dart';
import 'package:khadem/core/utils/colors.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;

  const MessageBubble({
    required this.message,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primaryColor
              : AppColors.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            if (!isMe)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isMe
                      ? AppColors.whiteColor
                      : AppColors.darkColor,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Text(
              time,
              style: TextStyle(
                fontSize: 9,
                color: isMe
                    ? AppColors.secondaryColor
                    : AppColors.greyColor,
              ),
            ),

            if (isMe) ...[
              const SizedBox(width: 3),
              const Icon(
                Icons.done_all_rounded,
                size: 14,
                color: AppColors.secondaryColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
