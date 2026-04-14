import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_text_styles.dart';
import 'package:programming_learn_app/ui/components/app_card.dart';

class DuoOptionCard extends StatelessWidget {
  const DuoOptionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    required this.selected,
    required this.onTap,
    this.accentColor,
    this.height = 64,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool selected;
  final VoidCallback onTap;
  final Color? accentColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.kGreen;
    final fillColor = selected ? color.withValues(alpha: 0.12) : AppColors.kWhite;
    final borderColor = selected ? color : AppColors.kGrayLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AppCard(
        color: fillColor,
        borderColor: borderColor,
        radius: 18,
        shadowColor: selected ? color : AppColors.kGrayLight,
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: height - 32,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: AppTextStyles.kH4),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!, style: AppTextStyles.kBodyXs.copyWith(height: 1.35)),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ).animate(target: selected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 140.ms),
    );
  }
}