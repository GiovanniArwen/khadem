// import 'package:flutter/material.dart';

// class AppColors {
//   static const Color primaryColor = Color(0xFF004aad);
//   static const Color secondaryColor = Color(0xFFCAD6FF);
//   static const Color accentColor = Color(0xFFE6EFF9);
//   static const Color redColor = Color(0xFFFF4667);
//   static const Color darkColor = Color(0xFF121212);
//   static const Color greyColor = Color(0xFFB4AAAA);
//   static const Color whiteColor = Color(0xFFFFFFFF);
  
// }

// lib/core/utils/app_colors.dart

// lib/core/utils/colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // ===== الأساسية =====
  static const Color primaryColor = Color(0xFF004AAD);
  static const Color secondaryColor = Color(0xFFCAD6FF);
  static const Color accentColor = Color(0xFFE6EFF9);
  static const Color redColor = Color(0xFFFF4667);
  static const Color darkColor = Color(0xFF121212);
  static const Color greyColor = Color(0xFFB4AAAA);
  static const Color whiteColor = Color(0xFFFFFFFF);

  // ===== إضافات الشاشتين =====

  /// الأزرق التاني في الجراديانت
  static const Color blueLightColor = Color(0xFF2962FF);

  /// خلفية الشاشة
  static const Color scaffoldColor = Color(0xFFF7F8FA);

  /// خلفية حقول الإدخال
  static const Color fieldColor = Color(0xFFF2F5FA);

  /// بوردر الكروت والحقول
  static const Color borderColor = Color(0xFFE7EAF0);

  /// خلفية أيقونات السكشن
  static const Color lightBlueColor = Color(0xFFEAF1FF);

  /// نص العناوين
  static const Color textDarkColor = Color(0xFF14213A);

  /// النص الثانوي
  static const Color textGreyColor = Color(0xFF6B7A90);

  /// الهنت جوه الحقول
  static const Color hintColor = Color(0xFF9AA5B8);

  /// خلفية زرار الحذف
  static const Color lightRedColor = Color(0xFFFDECEC);

  /// بوردر الأڤاتار وقت الخطأ (فوق الهيدر الأزرق)
  static const Color softRedColor = Color(0xFFFF8A8A);

  /// نص التحذير فوق الهيدر الأزرق
  static const Color warningTextColor = Color(0xFFFFD1D1);

  /// أساس ظل الكروت
  static const Color shadowColor = Color(0xFF0B1B3A);

  // ===== الجراديانت والظل =====
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [primaryColor, blueLightColor],
  );

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0D0B1B3A),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}