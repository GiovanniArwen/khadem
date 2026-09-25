import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/widgets/add_event_sheet.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/widgets/availabiliy_sheet.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/widgets/event_card.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:khadem/core/utils/colors.dart';
import 'package:khadem/core/utils/text_styles.dart';
import 'package:khadem/features/mainScreen/agenda/data/models/agenda_event_model.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/bloc/agenda_event.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/bloc/agenda_state.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key, required this.uid});

  final String uid;

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    print('================ AGENDA ================');
    print('AGENDA UID: "${widget.uid}"');
    print('UID EMPTY: ${widget.uid.isEmpty}');
    print('=========================================');

    if (widget.uid.isNotEmpty) {
      context.read<AgendaBloc>().add(LoadAgenda(widget.uid));
    }
  }

  // =========================================================
  // Events for selected day
  // =========================================================

  List<AgendaEventModel> _eventsForDay(
    List<AgendaEventModel> events,
    DateTime day,
  ) {
    return events.where((event) {
      final start = event.startTime;
      final end = event.endTime;

      if (start == null || end == null) {
        return false;
      }

      final dayOnly = DateTime(day.year, day.month, day.day);

      final startDay = DateTime(start.year, start.month, start.day);

      final endDay = DateTime(end.year, end.month, end.day);

      // Event appears on every day from start -> end
      return !dayOnly.isBefore(startDay) && !dayOnly.isAfter(endDay);
    }).toList();
  }

  // =========================================================
  // Availability
  // =========================================================

  bool _isAvailable(AgendaState state, DateTime day) {
    if (state is! AgendaLoaded) {
      return false;
    }

    final availability = state.availability.where((item) {
      if (item.date == null) {
        return false;
      }

      return isSameDay(item.date!, day);
    }).toList();

    if (availability.isEmpty) {
      return false;
    }

    return availability.first.isAvailable;
  }

  bool _hasAvailability(AgendaState state, DateTime day) {
    if (state is! AgendaLoaded) {
      return false;
    }

    return state.availability.any(
      (item) => item.date != null && isSameDay(item.date!, day),
    );
  }

  // =========================================================
  // Build
  // =========================================================

  @override
  Widget build(BuildContext context) {
    if (widget.uid.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('خطأ: UID المستخدم غير موجود')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.accentColor,

      appBar: AppBar(
        title: Text(
          'النوتة',
          style: TextStyles.title.copyWith(color: AppColors.accentColor),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),

      body: BlocBuilder<AgendaBloc, AgendaState>(
        builder: (context, state) {
          if (state is AgendaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AgendaError) {
            return Center(child: Text(state.message, style: TextStyles.body));
          }

          if (state is AgendaLoaded) {
            final dayEvents = _eventsForDay(state.events, _selectedDay);

            return Column(
              children: [
                _buildCalendar(state),

                const SizedBox(height: 10),

                _buildAvailabilityStatus(state),

                const SizedBox(height: 10),

                Expanded(
                  child: dayEvents.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: dayEvents.length,
                          itemBuilder: (context, index) {
                            final event = dayEvents[index];

                            return EventCard(
                              event: event,

                              // =========================
                              // Edit
                              // =========================
                              onEdit: () {
                                _showEventDialog(event: event);
                              },

                              // =========================
                              // Delete
                              // =========================
                              onDelete: () {
                                _deleteEvent(event);
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),

      // =====================================================
      // Add Event
      // =====================================================
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () {
          _showEventDialog();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // =========================================================
  // Event Dialog
  // =========================================================

  void _showEventDialog({AgendaEventModel? event}) {
    final agendaBloc = context.read<AgendaBloc>();

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: agendaBloc,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: AddEventSheet(uid: widget.uid, event: event),
          ),
        );
      },
    );
  }
  // =========================================================
  // Calendar
  // =========================================================

  Widget _buildCalendar(AgendaLoaded state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TableCalendar(
          locale: 'ar',

          firstDay: DateTime.utc(2020, 1, 1),

          lastDay: DateTime.utc(2035, 12, 31),

          focusedDay: _focusedDay,

          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },

          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },

          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },

          calendarFormat: CalendarFormat.month,

          availableCalendarFormats: const {CalendarFormat.month: 'شهر'},

          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),

          daysOfWeekHeight: 32,

          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyles.body.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            weekendStyle: TextStyles.body.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),

          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(.25),
              shape: BoxShape.circle,
            ),

            selectedDecoration: const BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),

            markerDecoration: const BoxDecoration(
              color: AppColors.hintColor,
              shape: BoxShape.circle,
            ),
          ),

          // ===================================================
          // Event markers
          // ===================================================
          eventLoader: (day) {
            return _eventsForDay(state.events, day);
          },

          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              if (!_hasAvailability(state, day)) {
                return null;
              }

              final available = _isAvailable(state, day);

              return Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: available
                        ? Colors.green.withOpacity(.18)
                        : Colors.red.withOpacity(.18),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyles.body.copyWith(
                      color: available
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Availability Status
  // =========================================================

  Widget _buildAvailabilityStatus(AgendaLoaded state) {
    final hasAvailability = _hasAvailability(state, _selectedDay);

    if (!hasAvailability) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.help_outline, color: Colors.grey),

            const SizedBox(width: 8),

            Text('لم يتم تحديد حالة التوفر لهذا اليوم', style: TextStyles.body),

            const Spacer(),

            TextButton(
              onPressed: _showAvailabilitySheet,
              child: const Text('تحديد'),
            ),
          ],
        ),
      );
    }

    final available = _isAvailable(state, _selectedDay);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: available
            ? Colors.green.withOpacity(.10)
            : Colors.red.withOpacity(.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            available ? Icons.check_circle : Icons.cancel,
            color: available ? Colors.green : Colors.red,
          ),

          const SizedBox(width: 10),

          Text(
            available ? 'أنت متاح في هذا اليوم' : 'أنت غير متاح في هذا اليوم',
            style: TextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),

          const Spacer(),

          TextButton(
            onPressed: _showAvailabilitySheet,
            child: const Text('تعديل'),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Empty State
  // =========================================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 60, color: Colors.grey.shade400),

          const SizedBox(height: 12),

          Text('لا توجد مواعيد لهذا اليوم', style: TextStyles.body),
        ],
      ),
    );
  }

  // =========================================================
  // Availability Dialog/Sheet
  // =========================================================

  void _showAvailabilitySheet() {
    final agendaBloc = context.read<AgendaBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondaryColor,
      builder: (_) => BlocProvider.value(
        value: agendaBloc,
        child: AvailabilitySheet(uid: widget.uid, date: _selectedDay),
      ),
    );
  }

  // =========================================================
  // Delete
  // =========================================================

  void _deleteEvent(AgendaEventModel event) {
    if (event.id == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف الموعد'),

          content: const Text('هل أنت متأكد أنك تريد حذف هذا الموعد؟'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('إلغاء'),
            ),

            TextButton(
              onPressed: () {
                context.read<AgendaBloc>().add(
                  DeleteAgendaEvent(uid: widget.uid, eventId: event.id!),
                );

                Navigator.pop(dialogContext);
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
