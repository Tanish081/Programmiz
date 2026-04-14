import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';

class AppTextStyles {
  static TextTheme textTheme(TextTheme base) {
    final nunito = GoogleFonts.nunitoTextTheme(base);
    return nunito.copyWith(
      displayLarge: kDisplay,
      headlineLarge: kH1,
      headlineMedium: kH2,
      headlineSmall: kH3,
      titleLarge: kH4,
      titleMedium: kH4,
      bodyLarge: kBody,
      bodyMedium: kBody,
      bodySmall: kBodySm,
      labelLarge: kLabel,
      labelMedium: kBodyXs,
      labelSmall: kBodyXs,
    );
  }

  static final TextStyle kDisplay = GoogleFonts.nunito(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: AppColors.kDark,
    height: 1.1,
  );

  static final TextStyle kH1 = GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.kDark,
    height: 1.2,
  );

  static final TextStyle kH2 = GoogleFonts.nunito(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.kDark,
    height: 1.3,
  );

  static final TextStyle kH3 = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.kDark,
    height: 1.3,
  );

  static final TextStyle kH4 = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.kDark,
    height: 1.4,
  );

  static final TextStyle kBody = GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.kDark,
    height: 1.6,
  );

  static final TextStyle kBodySm = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.kGrayMid,
    height: 1.5,
  );

  static final TextStyle kBodyXs = GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.kGrayMid,
    height: 1.4,
  );

  static final TextStyle kLabel = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.kGrayMid,
    letterSpacing: 1.0,
  );

  static const TextStyle kCode = TextStyle(
    fontFamily: 'monospace',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.7,
  );

  static const TextStyle kCodeSm = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.6,
  );

  static final TextStyle kBtnLg = GoogleFonts.nunito(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  static final TextStyle kBtnMd = GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  static final TextStyle kBtnSm = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: AppColors.kDark,
  );
}
