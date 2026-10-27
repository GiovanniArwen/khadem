import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class CompleteProfileEvent extends Equatable {
  const CompleteProfileEvent();

  @override
  List<Object?> get props => [];
}

class SaveCompleteProfileEvent extends CompleteProfileEvent {
  final bool isServant;
  final bool isChurchAdmin;

  final String name;
  final String email;
  final String password;

  final File? imageFile;

  final String phone1;
  final String? phone2;
  final String age;
  final String governorate;
  final String church;
  final String? bio;

  final List<String>? specialization;
  final String? instruments;

  final String? openHour;
  final String? closeHour;
  final String? meetingName;

  const SaveCompleteProfileEvent({
    required this.isServant,
    required this.isChurchAdmin,
    required this.name,
    required this.email,
    required this.password,
    required this.imageFile,
    required this.phone1,
    this.phone2,
    required this.age,
    required this.governorate,
    required this.church,
    this.bio,
    this.specialization,
    this.instruments,
    this.openHour,
    this.closeHour,
    this.meetingName,
  });

  @override
  List<Object?> get props => [
    isServant,
    isChurchAdmin,
    name,
    email,
    password,
    imageFile,
    phone1,
    phone2,
    age,
    governorate,
    church,
    bio,
    specialization,
    instruments,
    openHour,
    closeHour,
    meetingName,
  ];
}
