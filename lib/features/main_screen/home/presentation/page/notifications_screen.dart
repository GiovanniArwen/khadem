import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khadem/core/utils/text_styles.dart';
import 'package:khadem/features/main_screen/home/data/services/notification_inbox_service.dart';

class NotificationsScreen extends StatelessWidget {
  final Future<void> Function(
    BuildContext context,
    Map<String, dynamic> notification,
  )?
  onOpenNotification;

  const NotificationsScreen({super.key, this.onOpenNotification});

  static const Color _primaryColor = Color(0xFF004AAD);

  @override
  Widget build(BuildContext context) {
    final service = NotificationInboxService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,

        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: TextButton.icon(
              onPressed: () async {
                try {
                  await service.markAllAsRead();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تحديد كل الإشعارات كمقروءة'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (_) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تعذر تحديث الإشعارات. حاول مرة أخرى.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              label:  Text('قراءة الكل', style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: _primaryColor,
              ),),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF004AAD),
                backgroundColor: const Color(0xFFEAF1FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.watchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('تعذر تحميل الإشعارات. حاول مرة أخرى.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data?.docs ?? [];

          if (notifications.isEmpty) {
            return const _EmptyNotifications();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final document = notifications[index];
              final data = document.data();

              final type = data['type'] as String? ?? 'general';
              final title = data['title'] as String? ?? 'إشعار جديد';
              final body = data['body'] as String? ?? '';
              final isRead = data['isRead'] as bool? ?? false;

              final isChat = type == 'chat';
              final createdAt = data['createdAt'];

              DateTime? date;

              if (createdAt is Timestamp) {
                date = createdAt.toDate();
              }

              return Card(
                elevation: 0,
                color: isRead ? Colors.white : const Color(0xFFEAF1FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isRead
                        ? Colors.grey.shade200
                        : const Color(0xFFCAD6FF),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFCAD6FF),
                    child: Icon(
                      isChat
                          ? Icons.chat_bubble_outline_rounded
                          : Icons.campaign_outlined,
                      color: _primaryColor,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(body),
                        if (date != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _formatDate(date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  onTap: () async {
                    try {
                      if (!isRead) {
                        await service.markAsRead(document.id);
                      }

                      if (!context.mounted) return;

                      if (onOpenNotification != null) {
                        await onOpenNotification!(context, data);
                      } else {
                        await showDialog<void>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: Text(title),
                            content: Text(body),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('إغلاق'),
                              ),
                            ],
                          ),
                        );
                      }
                    } catch (_) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تعذر فتح الإشعار. حاول مرة أخرى.'),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year;
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day/$month/$year - $hour:$minute';
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'مفيش إشعارات لحد دلوقتي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'لما توصلك رسائل أو تحديثات جديدة هتظهر هنا.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
