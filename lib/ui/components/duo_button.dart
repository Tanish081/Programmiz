import 'package:flutter/material.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';

class DuoButton extends StatelessWidget {
  const DuoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.isBusy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final background = isPrimary ? AppColors.primary : AppColors.surface;
    final foreground = isPrimary ? Colors.white : AppColors.textPrimary;
    final borderColor = isPrimary ? Colors.transparent : AppColors.outline;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isBusy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background.withValues(alpha: 0.55),
          disabledForegroundColor: foreground.withValues(alpha: 0.65),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: borderColor),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isBusy
              ? const SizedBox(
                  key: ValueKey('busy'),
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                )
              : Text(
                  key: const ValueKey('label'),
                  label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
        ),
      ),
    );
  }
}