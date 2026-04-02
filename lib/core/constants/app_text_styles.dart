import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';

class AppTextStyles {
  static TextTheme textTheme(TextTheme base) {
    final nunito = GoogleFonts.nunitoTextTheme(base);
    return nunito.copyWith(
      titleLarge: nunito.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      titleMedium: nunito.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      bodyLarge: nunito.bodyLarge?.copyWith(color: AppColors.textPrimary),
      bodyMedium: nunito.bodyMedium?.copyWith(color: AppColors.textSecondary),
      bodySmall: nunito.bodySmall?.copyWith(color: AppColors.textSecondary),
    );
  }

  static const TextStyle code = TextStyle(
    fontFamily: 'monospace',
    fontSize: 14,
    height: 1.4,
    color: Colors.white,
  );
}
