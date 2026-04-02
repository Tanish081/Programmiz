import 'package:flutter/material.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';

class DuoOptionCard extends StatelessWidget {
  const DuoOptionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.primary : AppColors.outline;
    final fillColor = selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: selected ? 2 : 1.4),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.35),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}