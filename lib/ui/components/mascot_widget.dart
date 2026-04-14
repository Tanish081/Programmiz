import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_text_styles.dart';
import 'package:programming_learn_app/data/services/mascot_service.dart';

class MascotWidget extends StatelessWidget {
  const MascotWidget({
    super.key,
    required this.message,
    this.size = 80,
    this.onTap,
  });

  final MascotMessage message;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shadowColor = switch (message.state) {
      MascotState.celebrating => AppColors.kYellow,
      MascotState.excited => AppColors.kOrange,
      MascotState.proud => AppColors.kGreen,
      MascotState.sad => AppColors.kRed,
      MascotState.sleeping => AppColors.kGrayLight,
      MascotState.encouraging => AppColors.kBlue,
      MascotState.happy => AppColors.kGreen,
    };

    final bubbleColor = switch (message.state) {
      MascotState.sad => AppColors.kRedLight,
      MascotState.sleeping => AppColors.kGraySurface,
      MascotState.celebrating => AppColors.kYellowLight,
      MascotState.excited => AppColors.kOrangeLight,
      _ => AppColors.kWhite,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message.emoji, style: TextStyle(fontSize: size))
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(begin: 0, end: -8, duration: 1200.ms, curve: Curves.easeInOut)
              .then(delay: 10.ms)
              .shake(duration: message.state == MascotState.celebrating ? 500.ms : 0.ms),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.kGrayLight, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor.withValues(alpha: 0.15),
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    message.message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.kBodySm.copyWith(color: AppColors.kDark),
                  ),
                )
                    .animate()
                    .scale(begin: const Offset(0.8, 0.8), duration: 300.ms)
                    .fadeIn(duration: 300.ms),
                CustomPaint(size: const Size(18, 10), painter: _PointerPainter(color: bubbleColor, borderColor: AppColors.kGrayLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  _PointerPainter({required this.color, required this.borderColor});

  final Color color;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}