import 'package:flutter/material.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';

class LanguageCard extends StatelessWidget {
  const LanguageCard({
    super.key,
    required this.name,
    required this.icon,
    required this.subtitle,
    required this.available,
    required this.onTap,
  });

  final String name;
  final String icon;
  final String subtitle;
  final bool available;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: available ? Colors.white : const Color(0xFFF3F5EE),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: available ? AppColors.outline : const Color(0xFFE0E5D9), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: available ? 0.04 : 0.025),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const Spacer(),
                if (available)
                  _StatusPill(text: 'Start', color: AppColors.primary)
                else
                  _StatusPill(text: 'Soon', color: Colors.orange.shade400),
              ],
            ),
            const SizedBox(height: 14),
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.35)),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
    );
  }
}