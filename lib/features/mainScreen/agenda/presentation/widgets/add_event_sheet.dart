import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:khadem/core/utils/text_styles.dart';
import 'package:khadem/features/mainScreen/agenda/data/models/agenda_event_model.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/bloc/agenda_event.dart';

class AddEventSheet extends StatefulWidget {
  const AddEventSheet({super.key, required this.uid, this.event});

  final String uid;
  final AgendaEventModel? event;

  @override
  State<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<AddEventSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  DateTime? _startTime;
  DateTime? _endTime;

  bool get isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.event?.title ?? '');

    _descriptionController = TextEditingController(
      text: widget.event?.description ?? '',
    );

    _startTime = widget.event?.startTime;
    _endTime = widget.event?.endTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: keyboardHeight + 20,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Center(
                  child: Text(
                    isEditing ? 'تعديل الموعد' : 'إضافة موعد',
                    style: TextStyles.title,
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الموعد',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'اكتب عنوان الموعد';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                _buildDateTimeButton(
                  title: 'وقت البداية',
                  value: _startTime,
                  onTap: () => _pickDateTime(isStart: true),
                ),

                const SizedBox(height: 12),

                _buildDateTimeButton(
                  title: 'وقت النهاية',
                  value: _endTime,
                  onTap: () => _pickDateTime(isStart: false),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveEvent,
                    child: Text(isEditing ? 'حفظ التعديلات' : 'إضافة الموعد'),
                  ),
                ),

                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeButton({
    required String title,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value == null ? title : _formatDateTime(value),
                style: TextStyles.body,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initialDate = isStart
        ? _startTime ?? DateTime.now()
        : _endTime ?? _startTime ?? DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2035),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (time == null) return;

    final result = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = result;
      } else {
        _endTime = result;
      }
    });
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('حدد وقت البداية والنهاية')));

      return;
    }

    // النهاية لازم تكون بعد البداية
    if (!_endTime!.isAfter(_startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('وقت النهاية يجب أن يكون بعد البداية')),
      );

      return;
    }

    // Minimum duration = 2 hours
    final duration = _endTime!.difference(_startTime!);

    if (duration < const Duration(hours: 2)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مدة الموعد يجب ألا تقل عن ساعتين')),
      );

      return;
    }

    final event = AgendaEventModel(
      id: widget.event?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
    );

    if (isEditing) {
      context.read<AgendaBloc>().add(
        UpdateAgendaEvent(uid: widget.uid, event: event),
      );
    } else {
      context.read<AgendaBloc>().add(
        AddAgendaEvent(uid: widget.uid, event: event),
      );
    }

    Navigator.pop(context);
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
        ? 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'م' : 'ص';

    return '${date.day}/${date.month}/${date.year} - '
        '$hour:$minute $period';
  }
}
