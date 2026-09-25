import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/features/mainScreen/agenda/data/repo/agenda_repo.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/bloc/agenda_event.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/bloc/agenda_state.dart';
import 'package:khadem/features/mainScreen/servants/data/models/servant_model.dart';

class ServantDetailsScreen extends StatelessWidget {
  final ServantModel servant;

  const ServantDetailsScreen({super.key, required this.servant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بيانات الخادم')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 65,
              backgroundImage:
                  servant.image != null && servant.image!.isNotEmpty
                  ? NetworkImage(servant.image!)
                  : null,
              child: servant.image == null || servant.image!.isEmpty
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),

            const SizedBox(height: 16),

            Text(
              servant.name ?? 'بدون اسم',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            if (servant.specialization != null) ...[
              const SizedBox(height: 8),
              Text(
                servant.specialization!,
                style: const TextStyle(fontSize: 17),
              ),
            ],

            const SizedBox(height: 25),

            _InfoTile(
              icon: Icons.location_on_outlined,
              title: 'المحافظة',
              value: servant.governorate,
            ),

            _InfoTile(
              icon: Icons.church_outlined,
              title: 'الكنيسة',
              value: servant.church,
            ),

            _InfoTile(
              icon: Icons.home_outlined,
              title: 'العنوان',
              value: servant.address,
            ),

            _InfoTile(
              icon: Icons.info_outline,
              title: 'نبذة',
              value: servant.bio,
            ),

            const SizedBox(height: 20),

            // =========================
            // Availability / Agenda Note
            // =========================
            if (servant.uid != null) _buildAgendaSection(),

            const SizedBox(height: 20),

            // =========================
            // Actions
            // =========================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      pushTo(
                        context,
                        Routes.chat,
                        extra: {
                          'uid': servant.uid,
                          'name': servant.name ?? 'خادم',
                          'role': 'خادم',
                        },
                      );
                    },
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('محادثة'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: الدعوة
                    },
                    icon: const Icon(Icons.event_outlined),
                    label: const Text('دعوة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaSection() {
    // الخادم أخفى النوتة
    if (!servant.isNoteVisible) {
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (_) =>
          AgendaBloc(agendaRepo: AgendaRepo())..add(LoadAgenda(servant.uid!)),
      child: const _ServantAvailabilityCalendar(),
    );
  }
}

// =====================================================
// Calendar
// =====================================================

class _ServantAvailabilityCalendar extends StatefulWidget {
  const _ServantAvailabilityCalendar();

  @override
  State<_ServantAvailabilityCalendar> createState() =>
      _ServantAvailabilityCalendarState();
}

class _ServantAvailabilityCalendarState
    extends State<_ServantAvailabilityCalendar> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgendaBloc, AgendaState>(
      builder: (context, state) {
        if (state is AgendaLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AgendaError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'حدث خطأ أثناء تحميل مواعيد الخادم',
              style: TextStyle(color: Colors.red.shade700),
            ),
          );
        }

        if (state is! AgendaLoaded) {
          return const SizedBox.shrink();
        }

        return _buildCalendar(context, state);
      },
    );
  }

  Widget _buildCalendar(BuildContext context, AgendaLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نوتة التوفر',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            'اضغط على الأسهم للتنقل بين الشهور',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TableCalendar(
                locale: 'ar',
                firstDay: DateTime(
                  DateTime.now().year,
                  DateTime.now().month - 12,
                ),
                lastDay: DateTime(DateTime.now().year + 5, 12, 31),
                focusedDay: _focusedDay,

                startingDayOfWeek: StartingDayOfWeek.sunday,

                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.chevron_left),
                  rightChevronIcon: Icon(Icons.chevron_right),
                ),

                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  isTodayHighlighted: false,
                  cellMargin: EdgeInsets.symmetric(horizontal: 1, vertical: 3),
                ),

                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                  weekendStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),

                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },

                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    return _buildDay(context, day, state);
                  },

                  todayBuilder: (context, day, focusedDay) {
                    return _buildDay(context, day, state, isToday: true);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildDay(
    BuildContext context,
    DateTime day,
    AgendaLoaded state, {
    bool isToday = false,
  }) {
    final status = _getDayStatus(day, state);

    Color backgroundColor;
    Color textColor;

    switch (status) {
      case _DayStatus.available:
        backgroundColor = Colors.green.withOpacity(.15);
        textColor = Colors.green.shade700;
        break;

      case _DayStatus.unavailable:
        backgroundColor = Colors.red.withOpacity(.15);
        textColor = Colors.red.shade700;
        break;

      case _DayStatus.none:
        backgroundColor = Colors.grey.withOpacity(.06);
        textColor = Colors.grey.shade700;
        break;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  _DayStatus _getDayStatus(DateTime day, AgendaLoaded state) {
    // ==========================================
    // 1. مواعيد اليوم
    // ==========================================

    final dayEvents = state.events.where((event) {
      if (event.startTime == null) {
        return false;
      }

      return isSameDay(event.startTime!, day);
    }).toList();

    // ==========================================
    // 2. Availability اليدوي
    // ==========================================

    final availability = state.availability.where((item) {
      if (item.date == null) {
        return false;
      }

      return isSameDay(item.date!, day);
    }).toList();

    // ==========================================
    // 3. 3 مواعيد أو أكثر = غير متاح
    // ==========================================

    if (dayEvents.length >= 3) {
      return _DayStatus.unavailable;
    }

    // ==========================================
    // 4. لو الخادم حدد اليوم يدويًا
    // ==========================================

    if (availability.isNotEmpty) {
      final item = availability.first;

      if (item.isAvailable) {
        return _DayStatus.available;
      }

      return _DayStatus.unavailable;
    }

    // ==========================================
    // 5. عنده مواعيد ولكن أقل من 3
    // ==========================================

    if (dayEvents.isNotEmpty) {
      return _DayStatus.unavailable;
    }

    // ==========================================
    // 6. لا توجد بيانات
    // ==========================================

    return _DayStatus.none;
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _legendItem(color: Colors.green, text: 'متاح'),
        _legendItem(color: Colors.red, text: 'غير متاح'),
        _legendItem(color: Colors.grey, text: 'لا توجد بيانات'),
      ],
    );
  }

  Widget _legendItem({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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

enum _DayStatus { available, unavailable, none }

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) {
      return const SizedBox();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value!),
      ),
    );
  }
}
