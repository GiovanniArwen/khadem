
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khadem/core/services/media/cloudinary_service.dart';

class CompleteProfileRepo {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> saveProfile({
    required bool isServant,
    required bool isChurchAdmin,
    required String name,
    required String email,
    required String password,
    required String phone1,
    required String age,
    required String governorate,
    required String church,
    File? imageFile,
    String? phone2,
    String? bio,
    List<String>? specialization,
    String? openHour,
    String? closeHour,
    String? meetingName,
    String? instruments,
  }) async {
    User? user;
    var createdNewAccount = false;
    var profileSaved = false;

    try {
      final normalizedEmail = email.trim().toLowerCase();
      final currentUser = _auth.currentUser;

      // Reuse the signed-in account only if its email matches.
      if (currentUser != null) {
        if ((currentUser.email ?? '').trim().toLowerCase() !=
            normalizedEmail) {
          throw Exception(
            'الإيميل الحالي مختلف عن إيميل الحساب المسجل. '
            'سجّل الدخول بالحساب الصحيح ثم حاول مرة أخرى.',
          );
        }

        user = currentUser;
      } else {
        // A new account can only be created when a password is provided.
        if (password.isEmpty) {
          throw Exception(
            'انتهت جلسة تسجيل الدخول. سجّل الدخول مرة أخرى ثم أكمل بياناتك.',
          );
        }

        final credential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        user = credential.user;

        if (user == null) {
          throw Exception('تعذر إنشاء حساب Firebase.');
        }

        createdNewAccount = true;
      }

      final uid = user.uid;
      final userRef = _firestore.collection('users').doc(uid);
      final existingDoc = await userRef.get();
      final existingData = existingDoc.data() ?? <String, dynamic>{};

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await ProfileImageService.uploadProfileImage(
          uid: uid,
          file: imageFile,
        );
      }

      final Map<String, dynamic> data = {
        'uid': uid,
        'name': name.trim(),
        'email': email.trim(),
        'isServant': isServant,
        'isChurchAdmin': isChurchAdmin,
        'updatedAt': FieldValue.serverTimestamp(),
        'isProfileCompleted': true,
      };

      // Add createdAt only when this is the first profile document.
      if (!existingDoc.exists || existingData['createdAt'] == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      // Do not overwrite existing optional fields with empty values.
      if (phone1.trim().isNotEmpty) {
        data['phone1'] = phone1.trim();
        data['phone'] = phone1.trim();
      }

      if (phone2 != null && phone2.trim().isNotEmpty) {
        data['phone2'] = phone2.trim();
      }

      if (age.trim().isNotEmpty) {
        data['age'] = age.trim();
      }

      if (governorate.trim().isNotEmpty) {
        data['governorate'] = governorate.trim();
      }

      if (church.trim().isNotEmpty) {
        data['church'] = church.trim();
      }

      if (bio != null && bio.trim().isNotEmpty) {
        data['bio'] = bio.trim();
      }

      if (imageUrl != null) {
        data['image'] = imageUrl;
      }

      if (isServant) {
        data['servantStatus'] =
            existingData['servantStatus'] ?? 'approved';

        if (specialization != null) {
          data['specialization'] = specialization;
        }

        data['isNoteVisible'] = existingData['isNoteVisible'] ?? false;
        data['autoAvailabilityEnabled'] =
            existingData['autoAvailabilityEnabled'] ?? false;
        data['isAvailable'] = existingData['isAvailable'] ?? true;

        if (instruments != null && instruments.trim().isNotEmpty) {
          data['instruments'] = instruments
              .split(',')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList();
        }

        if (openHour != null && openHour.trim().isNotEmpty) {
          data['openHour'] = openHour;
        }

        if (closeHour != null && closeHour.trim().isNotEmpty) {
          data['closeHour'] = closeHour;
        }
      }

      if (isChurchAdmin) {
        data['churchAdminStatus'] =
            existingData['churchAdminStatus'] ?? 'approved';
      }

      // Meeting name may be required for either role.
      if (meetingName != null && meetingName.trim().isNotEmpty) {
        data['meetingName'] = meetingName.trim();
      }

      await userRef.set(data, SetOptions(merge: true));
      profileSaved = true;

      await user.updateDisplayName(name.trim());

      // Verification is only sent for newly created accounts.
      if (createdNewAccount) {
        try {
          await user.sendEmailVerification();
        } catch (_) {
          // Do not undo a successfully saved profile if email fails.
        }
      }
    } catch (error) {
      // Never delete an account that existed before this operation.
      // Only roll back a newly created account if saving the profile failed.
      if (createdNewAccount && !profileSaved && user != null) {
        try {
          await _firestore.collection('users').doc(user.uid).delete();
        } catch (_) {}

        try {
          await user.delete();
        } catch (_) {}
      }

      rethrow;
    }
  }
}
