import 'package:flutter/material.dart';
import 'package:khadem/core/constants/app_fonts.dart';
import 'package:khadem/core/utils/colors.dart';
import 'package:khadem/core/utils/text_styles.dart';

class AppThemes {
  static get lightTheme => ThemeData(
    scaffoldBackgroundColor: AppColors.whiteColor,

    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.whiteColor,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyles.title.copyWith(
        fontFamily: AppFonts.cairoFamily,
        color: AppColors.whiteColor,
      ),
    ),
    fontFamily: AppFonts.cairoFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      onSurface: AppColors.darkColor,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.whiteColor,
      showUnselectedLabels: false,
      showSelectedLabels: false,
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        foregroundColor: AppColors.darkColor,
      ),
    ),
    datePickerTheme: DatePickerThemeData(backgroundColor: Colors.white),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(color: Color(0xFF9FA8DA)),
      filled: true,
      fillColor: const Color(0xFFEDF2FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
  );
}
