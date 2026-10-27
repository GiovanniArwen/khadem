import 'package:cloud_firestore/cloud_firestore.dart';

class AgendaEventModel {
  String? id;
  String? title;
  String? description;
  DateTime? startTime;
  DateTime? endTime;

  AgendaEventModel({
    this.id,
    this.title,
    this.description,
    this.startTime,
    this.endTime,
  });

  factory AgendaEventModel.fromJson(Map<String, dynamic> json) {
    return AgendaEventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: (json['startTime'] as Timestamp?)?.toDate(),
      endTime: (json['endTime'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime':
          startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
    };
  }
}