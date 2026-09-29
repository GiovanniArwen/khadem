import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:khadem/features/mainScreen/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/bloc/agenda_event.dart';

class AvailabilitySheet extends StatelessWidget {
  const AvailabilitySheet({
    super.key,
    required this.uid,
    required this.date,
  });

  final String uid;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'تحديد التوفر',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${date.day}/${date.month}/${date.year}',
          ),

          const SizedBox(height: 25),

          // =========================
          // Available
          // =========================
          ListTile(
            leading: const Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
            title: const Text(
              'متاح',
            ),
            subtitle: const Text(
              'يمكن للمسؤول معرفة أنك متاح في هذا اليوم',
            ),
            onTap: () {
              context.read<AgendaBloc>().add(
                SetAvailability(
                  uid: uid,
                  date: date,
                  isAvailable: true,
                ),
              );

              Navigator.pop(context);
            },
          ),

          const Divider(),

          // =========================
          // Not Available
          // =========================
          ListTile(
            leading: const Icon(
              Icons.cancel,
              color: Colors.red,
            ),
            title: const Text(
              'غير متاح',
            ),
            subtitle: const Text(
              'سيظهر للمسؤول أنك غير متاح في هذا اليوم',
            ),
            onTap: () {
              context.read<AgendaBloc>().add(
                SetAvailability(
                  uid: uid,
                  date: date,
                  isAvailable: false,
                ),
              );

              Navigator.pop(context);
            },
          ),

          const Divider(),

          // =========================
          // Clear Availability
          // =========================
          ListTile(
            leading: const Icon(
              Icons.close,
              color: Colors.grey,
            ),
            title: const Text(
              'إلغاء تحديد التوفر',
            ),
            subtitle: const Text(
              'لن يتم تحديد حالتك لهذا اليوم',
            ),
            onTap: () {
              context.read<AgendaBloc>().add(
                DeleteAvailability(
                  uid: uid,
                  date: date,
                ),
              );

              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }
}