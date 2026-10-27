import 'package:cloud_firestore/cloud_firestore.dart';

class AvailabilityModel {
  String? id;
  DateTime? date;
  bool isAvailable;

  // هل السجل خاص بشهر كامل؟
  bool isMonthly;

  AvailabilityModel({
    this.id,
    this.date,
    this.isAvailable = true,
    this.isMonthly = false,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['id'] as String?,
      date: (json['date'] as Timestamp?)?.toDate(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      isMonthly: json['isMonthly'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'isAvailable': isAvailable,
      'isMonthly': isMonthly,
    };
  }

  String get dateKey {
    if (date == null) return '';

    final month = date!.month.toString().padLeft(2, '0');
    final day = date!.day.toString().padLeft(2, '0');

    return '${date!.year}-$month-$day';
  }

  String get monthKey {
    if (date == null) return '';

    final month = date!.month.toString().padLeft(2, '0');

    return '${date!.year}-$month';
  }
}
