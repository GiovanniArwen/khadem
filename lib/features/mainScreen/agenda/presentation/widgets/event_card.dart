import 'package:flutter/material.dart';

import 'package:khadem/core/utils/text_styles.dart';
import 'package:khadem/features/mainScreen/agenda/data/models/agenda_event_model.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  final AgendaEventModel event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  // =========================================================
  // Color palette (calm / muted colors)
  // =========================================================

  static const List<Color> _palette = [
    Color(0xFF3B82F6), // blue
    Color(0xFF8B5CF6), // purple
    Color(0xFF10B981), // green
    Color(0xFFF59E0B), // orange
    Color(0xFF14B8A6), // teal
    Color(0xFFEC4899), // pink
    Color(0xFF6366F1), // indigo
    Color(0xFF06B6D4), // cyan
  ];

  /// Deterministic color for this event: same event -> same color,
  /// even across rebuilds. Uses [event.id] when available, otherwise
  /// falls back to the title, otherwise a fixed default.
  Color get _eventColor {
    final String key = (event.id != null && event.id!.isNotEmpty)
        ? event.id!
        : (event.title != null && event.title!.isNotEmpty)
            ? event.title!
            : 'default_event_key';

    final int index = key.hashCode.abs() % _palette.length;
    return _palette[index];
  }

  // =========================================================
  // Time formatting (Arabic, RTL-safe, no dash)
  // =========================================================

  String _formatTime(DateTime time) {
    final int hour24 = time.hour;
    final String period = hour24 >= 12 ? 'م' : 'ص';

    int hour12 = hour24 % 12;
    if (hour12 == 0) hour12 = 12;

    final String minute = time.minute.toString().padLeft(2, '0');

    return '$hour12:$minute $period';
  }

  String? _durationLabel() {
    final start = event.startTime;
    final end = event.endTime;

    if (start == null || end == null) return null;

    final diff = end.difference(start);
    if (diff.isNegative) return null;

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if (hours == 0 && minutes == 0) return null;

    final parts = <String>[];
    if (hours > 0) parts.add('$hours ساعة');
    if (minutes > 0) parts.add('$minutes دقيقة');

    return parts.join(' و');
  }

  // =========================================================
  // Build
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final start = event.startTime;
    final end = event.endTime;
    final color = _eventColor;
    final hasDescription =
        event.description != null && event.description!.isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        color: color.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color.withOpacity(0.18), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showDetails(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colored indicator
                Container(
                  width: 4,
                  height: 42,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        event.title ?? 'بدون عنوان',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 3),

                      if (start != null && end != null)
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text.rich(
                            TextSpan(
                              style: TextStyles.body.copyWith(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                              children: [
                                const TextSpan(text: 'من '),
                                TextSpan(
                                  text: _formatTime(start),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' إلى '),
                                TextSpan(
                                  text: _formatTime(end),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (hasDescription) ...[
                        const SizedBox(height: 3),
                        Text(
                          event.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.body.copyWith(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Popup menu — tapping it must NOT open Details.
                SizedBox(
                  height: 32,
                  width: 32,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('تعديل'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'حذف',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Details bottom sheet
  // =========================================================

  void _showDetails(BuildContext context) {
    final start = event.startTime;
    final end = event.endTime;
    final duration = _durationLabel();
    final color = _eventColor;
    final hasDescription =
        event.description != null && event.description!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),

                      // Title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 26,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              event.title ?? 'بدون عنوان',
                              style: TextStyles.title.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      if (start != null && end != null) ...[
                        _DetailRow(
                          icon: Icons.schedule,
                          color: color,
                          child: Text.rich(
                            TextSpan(
                              style: TextStyles.body,
                              children: [
                                const TextSpan(text: 'من '),
                                TextSpan(
                                  text: _formatTime(start),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: '  إلى '),
                                TextSpan(
                                  text: _formatTime(end),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (duration != null) ...[
                        _DetailRow(
                          icon: Icons.timelapse,
                          color: color,
                          child: Text(
                            'المدة: $duration',
                            style: TextStyles.body,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (hasDescription) ...[
                        _DetailRow(
                          icon: Icons.notes,
                          color: color,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          child: Text(
                            event.description!,
                            style: TextStyles.body.copyWith(
                              color: Colors.grey.shade800,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// =========================================================
// Small helper row used inside the Details sheet
// =========================================================

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.color,
    required this.child,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final IconData icon;
  final Color color;
  final Widget child;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: child),
      ],
    );
  }
}