import 'package:flutter/material.dart';
import 'package:khadem/core/utils/colors.dart';

/// دوال مساعدة للتاريخ والوقت في الشات (من غير أي package إضافي)
/// حطها في: features/mainScreen/chat/presentation/widgets/date_separator.dart
class ChatDateUtils {
  ChatDateUtils._();

  // DateTime.weekday: 1 = الاثنين ... 7 = الأحد
  static const _weekdays = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static const _months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  /// هل الرسالة دي أول رسالة في يومها؟
  /// [previous] = تاريخ الرسالة اللي قبلها في الزمن (الأقدم)، أو null لو مفيش.
  static bool startsNewDay(DateTime current, DateTime? previous) {
    if (previous == null) return true;
    final a = current.toLocal();
    final b = previous.toLocal();
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  /// اليوم • 20 سبتمبر 2026  /  أمس • 19 سبتمبر 2026
  /// الخميس • 17 سبتمبر 2026 (آخر أسبوع)  /  12 أغسطس 2026 (أقدم من كده)
  static String dayLabel(DateTime date, {DateTime? now}) {
    final n = (now ?? DateTime.now()).toLocal();
    final d = date.toLocal();

    // UTC عشان فرق التوقيت الصيفي ميبوظش حساب الأيام
    final today = DateTime.utc(n.year, n.month, n.day);
    final day = DateTime.utc(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;

    if (diff < 7) {
      final relative = diff <= 0
          ? 'اليوم'
          : diff == 1
          ? 'أمس'
          : _weekdays[d.weekday - 1];
      return '$relative • ${fullDate(d)}';
    }

    return fullDate(d);
  }

  /// 20 سبتمبر 2026
  static String fullDate(DateTime date) {
    final d = date.toLocal();
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  /// الوقت بصيغة 3:45 م
  static String time(DateTime dateTime) {
    final d = dateTime.toLocal();
    int hour = d.hour;
    final minute = d.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute ${isPm ? 'م' : 'ص'}';
  }
}

/// كبسولة التاريخ اللي بتظهر فوق أول رسالة في كل يوم
class DateSeparator extends StatelessWidget {
  final DateTime date;

  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE9ECF4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          ChatDateUtils.dayLabel(date),
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.greyColor,
          ),
        ),
      ),
    );
  }
}
