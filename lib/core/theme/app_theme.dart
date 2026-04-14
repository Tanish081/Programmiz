import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_text_styles.dart';

ThemeData get appTheme => ThemeData(
  useMaterial3: true,
  fontFamily: GoogleFonts.nunito().fontFamily,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.kGreen,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: AppColors.kWhite,
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.kWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.kWhite,
    selectedItemColor: AppColors.kGreen,
    unselectedItemColor: AppColors.kGrayMid,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    backgroundColor: AppColors.kDark,
    contentTextStyle: AppTextStyles.kBodySm.copyWith(color: AppColors.kWhite),
  ),
);
