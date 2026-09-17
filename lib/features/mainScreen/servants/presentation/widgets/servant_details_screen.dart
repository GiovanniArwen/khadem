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

            // ============== النوتة (حسب إذن الخادم) ==============
            if (servant.uid != null) _buildAgendaSection(),

            const SizedBox(height: 20),

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
                      // TODO: منطق الدعوة (يمكن يبقى إرسال رسالة agenda event مقترح)
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
    if (!servant.isNoteVisible) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: const [
            Icon(Icons.visibility_off_outlined, color: Colors.grey),
            SizedBox(width: 10),
            Expanded(child: Text('هذا الخادم أخفى نوتته عن المسؤولين')),
          ],
        ),
      );
    }

    return BlocProvider(
      create: (_) =>
          AgendaBloc(agendaRepo: AgendaRepo())..add(LoadAgenda(servant.uid!)),
      child: BlocBuilder<AgendaBloc, AgendaState>(
        builder: (context, state) {
          if (state is AgendaLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is! AgendaLoaded) return const SizedBox();

          final today = DateTime.now();
          final days = List.generate(
            7,
            (i) => DateTime(today.year, today.month, today.day + i),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'نوتة التوفر',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              ...days.map((day) {
                final match = state.availability
                    .where((a) => a.date != null && isSameDay(a.date!, day))
                    .toList();

                final hasStatus = match.isNotEmpty;
                final available = hasStatus && match.first.isAvailable;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: !hasStatus
                        ? Colors.grey.withOpacity(.08)
                        : available
                        ? Colors.green.withOpacity(.10)
                        : Colors.red.withOpacity(.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text('${day.day}/${day.month}'),
                      const Spacer(),
                      Text(
                        !hasStatus
                            ? 'غير محدد'
                            : available
                            ? 'متاح'
                            : 'غير متاح',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: !hasStatus
                              ? Colors.grey
                              : available
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}

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
    if (value == null || value!.isEmpty) return const SizedBox();

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
