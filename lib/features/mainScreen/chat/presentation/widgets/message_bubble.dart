import 'package:flutter/material.dart';
import 'package:khadem/core/utils/colors.dart';

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
      .toColor();
}

class MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.78;
    const big = Radius.circular(20);
    const small = Radius.circular(6);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth, minWidth: 96),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        decoration: BoxDecoration(
          color: isMe ? null : AppColors.whiteColor,
          gradient: isMe
              ? LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.primaryColor,
                    _darken(AppColors.primaryColor, 0.07),
                  ],
                )
              : null,
          border: isMe ? null : Border.all(color: const Color(0xFFE8EAF0)),
          borderRadius: BorderRadius.only(
            topLeft: big,
            topRight: big,
            bottomLeft: isMe ? big : small,
            bottomRight: isMe ? small : big,
          ),
          boxShadow: [
            BoxShadow(
              color: isMe
                  ? AppColors.primaryColor.withOpacity(0.22)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: isMe ? AppColors.whiteColor : AppColors.darkColor,
                ),
              ),

              const SizedBox(height: 6),

              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe
                            ? AppColors.secondaryColor
                            : AppColors.greyColor,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.done_all_rounded,
                        size: 15,
                        color: AppColors.secondaryColor,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}