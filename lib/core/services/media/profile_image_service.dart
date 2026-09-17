// // lib/core/services/media/profile_image_service.dart
// //
// // pubspec.yaml:
// //   image_picker: ^1.1.2
// //   firebase_storage: ^12.3.7
// //
// // Android: يحتاج minSdk 21+
// // iOS: أضف في Info.plist
// //   NSPhotoLibraryUsageDescription  -> نحتاج الوصول للصور لاختيار صورة البروفايل
// //   NSCameraUsageDescription        -> نحتاج الكاميرا لالتقاط صورة البروفايل

// import 'dart:convert';
// import 'dart:io';

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';

// class ProfileImageService {
//   ProfileImageService._();

//   static final ImagePicker _picker = ImagePicker();

//   /// اختيار صورة من المعرض أو الكاميرا مع ضغطها قبل الرفع
//   static Future<File?> pickImage({
//     required ImageSource source,
//   }) async {
//     final XFile? picked = await _picker.pickImage(
//       source: source,
//       imageQuality: 70,
//       maxWidth: 800,
//       maxHeight: 800,
//     );

//     if (picked == null) return null;

//     return File(picked.path);
//   }

//   /// رفع الصورة على Firebase Storage ورجوع الرابط
//   static Future<String> uploadProfileImage({
//     required String uid,
//     required File file,
//   }) async {
//     final ref = FirebaseStorage.instance
//         .ref()
//         .child('profile_images')
//         .child('$uid.jpg');

//     await ref.putFile(
//       file,
//       SettableMetadata(contentType: 'image/jpeg'),
//     );

//     return await ref.getDownloadURL();
//   }

//   /// بديل لو Firebase Storage مش مفعّل عندك (محتاج خطة Blaze).
//   /// بنخزّن الصورة نفسها كـ base64 جوه دوكيومنت الـ Firestore.
//   /// مناسب فقط للصور الصغيرة (أقل من 1 ميجا بعد الضغط).
//   static Future<String> encodeAsBase64(File file) async {
//     final bytes = await file.readAsBytes();
//     return 'data:image/jpeg;base64,${base64Encode(bytes)}';
//   }
// }