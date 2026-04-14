import 'package:flutter/material.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.color = AppColors.kWhite,
    this.borderColor = AppColors.kGrayLight,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
    this.shadowColor,
    this.gradient,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final EdgeInsets padding;
  final double radius;
  final Color? shadowColor;
  final Gradient? gradient;

  const AppCard.colored({
    super.key,
    required this.child,
    required Color color,
    this.borderColor = Colors.transparent,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
    this.shadowColor,
    this.gradient,
  }) : color = color;

  const AppCard.dark({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
    this.shadowColor,
    this.gradient,
  })  : color = AppColors.kDark,
        borderColor = Colors.transparent;

  const AppCard.success({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
    this.shadowColor,
    this.gradient,
  })  : color = AppColors.kGreenSurface,
        borderColor = AppColors.kGreenLight;

  const AppCard.warning({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
    this.shadowColor,
    this.gradient,
  })  : color = AppColors.kOrangeLight,
        borderColor = AppColors.kOrange;

  const AppCard.danger({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
    this.shadowColor,
    this.gradient,
  })  : color = AppColors.kRedLight,
        borderColor = AppColors.kRed;

  @override
  Widget build(BuildContext context) {
    final resolvedShadow = shadowColor ?? borderColor;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? color : Colors.transparent,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: resolvedShadow.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
