import 'package:flutter/material.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_text_styles.dart';

class StreakChip extends StatelessWidget {
  const StreakChip({
    super.key,
    required this.streak,
  });

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.kOrange,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '🔥 $streak',
        style: AppTextStyles.kBodyXs.copyWith(
          color: AppColors.kWhite,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
