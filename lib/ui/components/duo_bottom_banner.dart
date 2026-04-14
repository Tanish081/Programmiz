import 'package:flutter/material.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_text_styles.dart';
import 'package:programming_learn_app/ui/components/app_card.dart';
import 'package:programming_learn_app/ui/components/duo_button.dart';

class DuoBottomBanner extends StatelessWidget {
  const DuoBottomBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.backgroundColor,
  });

  final String title;
  final String subtitle;
  final Widget? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final fillColor = backgroundColor ?? AppColors.surface;

    return AppCard.colored(
      color: fillColor,
      borderColor: AppColors.kGrayLight,
      shadowColor: AppColors.kGrayLight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.kH4),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.kBodySm),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 12),
            DuoButton(
              label: actionLabel!,
              onPressed: onAction,
              style: DuoButtonStyle.ghost,
              size: DuoButtonSize.small,
            ),
          ],
        ],
      ),
    );
  }
}