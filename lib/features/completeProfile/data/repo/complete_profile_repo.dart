// lib/features/completeProfile/data/repo/complete_profile_repo.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khadem/core/services/cloudinary_service.dart';

class CompleteProfileRepo {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> saveProfile({
    required String uid,
    required bool isServant,
    required bool isChurchAdmin,
    required String name,
    required String email,
    required String phone1,
    required String age,
    required String governorate,
    required String church,
    File? imageFile,
    String? phone2,
    String? bio,
    String? specialization,
    String? openHour,
    String? closeHour,
    String? meetingName,
  }) async {
    // 1) رفع الصورة الأول (لو موجودة)
    String? imageUrl;

    if (imageFile != null) {
      // رفع على Cloudinary (مجاني، من غير خطة Blaze)
      imageUrl = await ProfileImageService.uploadProfileImage(
        uid: uid,
        file: imageFile,
      );

      // بديل احتياطي بدون أي سيرفر خارجي — تخزين الصورة كـ base64 جوه Firestore:
      // imageUrl = await ProfileImageService.encodeAsBase64(imageFile);
    }

    // 2) تجهيز الداتا
    final Map<String, dynamic> data = {
      'uid': uid,
      'name': name,
      'email': email,
      'phone1': phone1,
      'phone': phone1, // نفس الرقم لمسؤول الاجتماع
      'age': age,
      'governorate': governorate,
      'church': church,
      'isProfileCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (imageUrl != null) {
      data['image'] = imageUrl;
    }

    if (phone2 != null && phone2.isNotEmpty) {
      data['phone2'] = phone2;
    }

    if (bio != null && bio.isNotEmpty) {
      data['bio'] = bio;
    }

    if (isServant) {
      data['specialization'] = specialization;
      data['isNoteVisible'] = false;
      data['autoAvailabilityEnabled'] = false;
      data['isAvailable'] = true;

      if (openHour != null) data['openHour'] = openHour;
      if (closeHour != null) data['closeHour'] = closeHour;
    }

    if (isChurchAdmin && meetingName != null) {
      data['meetingName'] = meetingName;
    }

    // 3) الحفظ
    await _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }
}
