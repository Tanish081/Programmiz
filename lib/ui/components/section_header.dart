import 'package:flutter/material.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    this.title,
    this.label,
    this.subtitle,
    this.compact = false,
    this.actionText,
    this.onAction,
  });

  final String? title;
  final String? label;
  final String? subtitle;
  final bool compact;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? label ?? '';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resolvedTitle,
                style: compact ? AppTextStyles.kH4.copyWith(fontWeight: FontWeight.w900) : AppTextStyles.kLabel,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTextStyles.kBodySm.copyWith(color: AppColors.kGrayMid),
                ),
              ],
            ],
          ),
        ),
        if (actionText != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText!,
              style: AppTextStyles.kBodySm.copyWith(color: AppColors.kGreen, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}
