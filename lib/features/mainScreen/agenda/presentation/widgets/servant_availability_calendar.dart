import 'package:flutter/material.dart';

import 'package:khadem/features/mainScreen/agenda/data/models/agenda_event_model.dart';
import 'package:khadem/features/mainScreen/agenda/data/models/availability_model.dart';

class ServantAvailabilityCalendar extends StatefulWidget {
  const ServantAvailabilityCalendar({
    super.key,
    required this.events,
    required this.availability,
  });

  final List<AgendaEventModel> events;
  final List<AvailabilityModel> availability;

  @override
  State<ServantAvailabilityCalendar> createState() =>
      _ServantAvailabilityCalendarState();
}

class _ServantAvailabilityCalendarState
    extends State<ServantAvailabilityCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _currentMonth = DateTime(now.year, now.month);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildHeader(),

          const SizedBox(height: 20),

          _buildWeekDays(),

          const SizedBox(height: 10),

          _buildCalendar(),

          const SizedBox(height: 16),

          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final monthName = _getArabicMonth(_currentMonth.month);

    return Row(
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: const Icon(Icons.chevron_left),
        ),

        Expanded(
          child: Column(
            children: [
              Text(
                monthName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                '${_currentMonth.year}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: _nextMonth,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildWeekDays() {
    const days = ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];

    return Row(
      children: days.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendar() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);

    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;

    final firstWeekday = firstDay.weekday % 7;

    final totalCells = firstWeekday + daysInMonth;

    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Row(
          children: List.generate(7, (columnIndex) {
            final index = rowIndex * 7 + columnIndex;

            if (index < firstWeekday || index >= firstWeekday + daysInMonth) {
              return const Expanded(child: SizedBox(height: 52));
            }

            final day = index - firstWeekday + 1;

            final date = DateTime(_currentMonth.year, _currentMonth.month, day);

            return Expanded(child: _buildDay(date));
          }),
        );
      }),
    );
  }

  Widget _buildDay(DateTime date) {
    final status = _getDayStatus(date);

    Color backgroundColor;
    Color textColor;

    switch (status) {
      case DayStatus.available:
        backgroundColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green.shade700;
        break;

      case DayStatus.unavailable:
        backgroundColor = Colors.red.withOpacity(0.15);
        textColor = Colors.red.shade700;
        break;

      case DayStatus.none:
        backgroundColor = Colors.grey.withOpacity(0.08);
        textColor = Colors.grey.shade700;
        break;
    }

    final isToday = _isSameDay(date, DateTime.now());

    return Container(
      height: 52,
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }

  DayStatus _getDayStatus(DateTime date) {
    final availability = _findAvailability(date);

    final dayEvents = widget.events.where((event) {
      if (event.startTime == null) return false;

      return _isSameDay(event.startTime!, date);
    }).toList();

    // 3 مواعيد أو أكثر = غير متاح
    if (dayEvents.length >= 3) {
      return DayStatus.unavailable;
    }

    // Availability اليدوي له الأولوية
    if (availability != null) {
      if (availability.isAvailable) {
        return DayStatus.available;
      }

      return DayStatus.unavailable;
    }

    // لو عنده مواعيد لكن أقل من 3
    if (dayEvents.isNotEmpty) {
      return DayStatus.unavailable;
    }

    return DayStatus.none;
  }

  AvailabilityModel? _findAvailability(DateTime date) {
    for (final item in widget.availability) {
      if (item.date == null) continue;

      if (_isSameDay(item.date!, date)) {
        return item;
      }
    }

    return null;
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _getArabicMonth(int month) {
    const months = [
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

    return months[month - 1];
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(color: Colors.green, text: 'متاح'),
        const SizedBox(width: 18),
        _legendItem(color: Colors.red, text: 'غير متاح'),
        const SizedBox(width: 18),
        _legendItem(color: Colors.grey, text: 'لا توجد بيانات'),
      ],
    );
  }

  Widget _legendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

enum DayStatus { available, unavailable, none }
