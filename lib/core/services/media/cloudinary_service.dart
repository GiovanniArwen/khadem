// lib/core/services/media/profile_image_service.dart
//
// pubspec.yaml:
//   image_picker: ^1.1.2
//   http: ^1.2.2
//
// Android: minSdk 21+
// iOS: أضف في Info.plist
//   NSPhotoLibraryUsageDescription
//   NSCameraUsageDescription

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileImageService {
  ProfileImageService._();

  // ========================================
  // غيّر القيمتين دول بس بتاعتك من Cloudinary
  // ========================================
  static const String _cloudName = 'ngok9cfc'; // Cloud Name بتاعك
  static const String _uploadPreset =
      'khadem_profile_images'; // اسم الـ Unsigned Preset

  static final ImagePicker _picker = ImagePicker();

  /// اختيار صورة من المعرض أو الكاميرا مع ضغطها قبل الرفع
  static Future<File?> pickImage({required ImageSource source}) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (picked == null) return null;

    return File(picked.path);
  }

  /// رفع الصورة على Cloudinary ورجوع رابط الصورة (secure_url)
  /// رفع الصورة على Cloudinary ورجوع رابط الصورة الجديد
  static Future<String> uploadProfileImage({
    required String uid,
    required File file,
  }) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final uniquePublicId = '${uid}_${DateTime.now().millisecondsSinceEpoch}';

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['public_id'] = uniquePublicId
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('Cloudinary response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'فشل رفع الصورة (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final secureUrl = data['secure_url'] as String?;

    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary لم يرجع رابط الصورة');
    }

    debugPrint('Cloudinary secure_url: $secureUrl');
    debugPrint('Cloudinary public_id: ${data['public_id']}');
    debugPrint('Cloudinary version: ${data['version']}');

    return secureUrl;
  }

  /// بديل احتياطي: تخزين الصورة نفسها كـ base64 جوه Firestore
  /// (مناسب فقط لصور صغيرة أقل من 1 ميجا بعد الضغط)
  static Future<String> encodeAsBase64(File file) async {
    final bytes = await file.readAsBytes();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }
}
