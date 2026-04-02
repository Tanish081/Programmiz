import 'package:flutter/material.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';

class DuoXpToast extends StatelessWidget {
  const DuoXpToast({super.key, required this.xp, required this.message});

  final int xp;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('+${xp} XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              Text(message, style: TextStyle(color: Colors.white.withValues(alpha: 0.86), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}