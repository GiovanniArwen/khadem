import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/core/utils/colors.dart';
import 'package:khadem/features/main_screen/chat/data/models/message_reaction_model.dart';
import 'package:khadem/features/main_screen/chat/presentation/bloc/chat_bloc.dart';

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

class MessageBubble extends StatelessWidget {
  final String message;
  final String messageId;
  final String otherUserId;
  final String time;
  final bool isMe;
  final bool isDeleted;
  const MessageBubble({
    super.key,
    required this.message,
    required this.messageId,
    required this.otherUserId,
    required this.time,
    required this.isMe,
    this.isDeleted = false,
  });

  static const List<String> _emojis = ['👍', '❤️', '😂', '🙏', '😮'];

  Future<void> _showReactions(BuildContext context) async {
    final repo = context.read<ChatBloc>().chatRepo;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _emojis.map((emoji) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () async {
                        Navigator.of(sheetContext).pop();

                        try {
                          await repo.toggleMessageReaction(
                            otherUserId: otherUserId,
                            messageId: messageId,
                            emoji: emoji,
                          );
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تعذر إضافة التفاعل، حاول مرة أخرى',
                              ),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (isMe) ...[
                  const Divider(height: 20),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'حذف لدى الطرفين',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _confirmDeleteMessage(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteMessage(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الرسالة؟'),
        content: const Text(
          'سيتم حذف محتوى الرسالة من المحادثة عندك وعند الطرف الآخر.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف لدى الطرفين'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    try {
      await context.read<ChatBloc>().chatRepo.deleteMessageForEveryone(
        otherUserId: otherUserId,
        messageId: messageId,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حذف الرسالة، حاول مرة أخرى')),
      );
    }
  }

  Future<void> _toggleReaction(BuildContext context, String emoji) async {
    try {
      await context.read<ChatBloc>().chatRepo.toggleMessageReaction(
        otherUserId: otherUserId,
        messageId: messageId,
        emoji: emoji,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تحديث التفاعل، حاول مرة أخرى')),
      );
    }
  }

  Widget _buildReactionBar(
    BuildContext context,
    List<MessageReactionModel> reactions,
    String currentUid,
  ) {
    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final counts = <String, int>{};

    for (final reaction in reactions) {
      counts[reaction.emoji] = (counts[reaction.emoji] ?? 0) + 1;
    }

    final orderedEmojis = counts.keys.toList();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: orderedEmojis.map((emoji) {
          final selectedByMe = reactions.any(
            (reaction) =>
                reaction.userId == currentUid && reaction.emoji == emoji,
          );

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _toggleReaction(context, emoji),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: selectedByMe ? const Color(0xFFE0E9FF) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selectedByMe
                      ? AppColors.primaryColor
                      : const Color(0xFFE1E5ED),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 4),
                  Text(
                    '${counts[emoji]}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.82;

    final chatRepo = context.read<ChatBloc>().chatRepo;
    final currentUid = chatRepo.currentUid;

    const big = Radius.circular(20);
    const small = Radius.circular(6);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: GestureDetector(
                  onLongPress: isDeleted ? null : () => _showReactions(context),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 96),
                    padding: const EdgeInsets.fromLTRB(10, 12, 16, 8),
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
                      border: isMe
                          ? null
                          : Border.all(color: const Color(0xFFE8EAF0)),
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
                              fontStyle: isDeleted
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              fontWeight: isDeleted
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                              color: isDeleted
                                  ? (isMe
                                        ? AppColors.secondaryColor
                                        : AppColors.greyColor)
                                  : (isMe
                                        ? AppColors.whiteColor
                                        : AppColors.darkColor),
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
                ),
              ),
            ),
            const SizedBox(height: 2),
            if (!isDeleted)
              StreamBuilder<List<MessageReactionModel>>(
                stream: chatRepo.getMessageReactions(
                  otherUserId: otherUserId,
                  messageId: messageId,
                ),
                builder: (context, snapshot) {
                  final reactions =
                      snapshot.data ?? const <MessageReactionModel>[];

                  if (reactions.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: _buildReactionBar(context, reactions, currentUid),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
