// lib/features/completeProfile/presentation/bloc/complete_profile_event.dart

import 'dart:io';

abstract class CompleteProfileEvent {}

class SaveCompleteProfileEvent extends CompleteProfileEvent {
  final String uid;

  final bool isServant;
  final bool isChurchAdmin;

  final String name;
  final String email;

  /// إجبارية للخادم، اختيارية لمسؤول الاجتماع
  final File? imageFile;

  final String phone1;
  final String? phone2;

  final String age;
  final String governorate;
  final String church;

  final String? bio;

  // الخادم
  final String? specialization;
  final String? openHour;
  final String? closeHour;

  // مسؤول الاجتماع
  final String? meetingName;

  SaveCompleteProfileEvent({
    required this.uid,
    required this.isServant,
    required this.isChurchAdmin,
    required this.name,
    required this.email,
    required this.phone1,
    required this.age,
    required this.governorate,
    required this.church,
    this.imageFile,
    this.phone2,
    this.bio,
    this.specialization,
    this.openHour,
    this.closeHour,
    this.meetingName,
  });
}
