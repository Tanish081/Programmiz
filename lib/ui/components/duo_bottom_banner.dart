import 'package:flutter/material.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';

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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outline),
      ),
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
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ],
      ),
    );
  }
}