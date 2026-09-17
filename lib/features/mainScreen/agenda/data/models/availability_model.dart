import 'package:cloud_firestore/cloud_firestore.dart';

class AvailabilityModel {
  String? id;
  DateTime? date;
  bool isAvailable;

  AvailabilityModel({
    this.id,
    this.date,
    this.isAvailable = true,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['id'],
      date: (json['date'] as Timestamp?)?.toDate(),
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'isAvailable': isAvailable,
    };
  }
}