import 'package:flutter/material.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_text_styles.dart';

class XpChip extends StatelessWidget {
  const XpChip({
    super.key,
    required this.xp,
    this.large = false,
  });

  final int xp;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final padding = large ? const EdgeInsets.symmetric(horizontal: 14, vertical: 6) : const EdgeInsets.symmetric(horizontal: 8, vertical: 3);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.kYellow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '+$xp XP',
        style: AppTextStyles.kBodyXs.copyWith(
          color: AppColors.kDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
