import 'package:flutter/material.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';

class DuoProgressBar extends StatelessWidget {
  const DuoProgressBar({
    super.key,
    required this.value,
    this.backgroundColor,
    this.color,
    this.height = 14,
  });

  final double value;
  final Color? backgroundColor;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 1).toDouble();
    final trackColor = backgroundColor ?? AppColors.outline.withValues(alpha: 0.7);
    final fillColor = color ?? AppColors.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: clamped),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, _) {
          return LinearProgressIndicator(
            value: animatedValue,
            minHeight: height,
            backgroundColor: trackColor,
            valueColor: AlwaysStoppedAnimation<Color>(fillColor),
          );
        },
      ),
    );
  }
}