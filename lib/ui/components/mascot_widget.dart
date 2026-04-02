import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final mascot = Text(message.emoji, style: TextStyle(fontSize: size));
    final isCelebrating = message.state == MascotState.celebrating;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          mascot
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(begin: 0, end: -8, duration: 1200.ms, curve: Curves.easeInOut)
              .then(delay: 10.ms)
              .shake(duration: isCelebrating ? 500.ms : 0.ms),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
                  ),
                  child: Text(
                    message.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                )
                    .animate()
                    .scale(begin: const Offset(0.8, 0.8), duration: 300.ms)
                    .fadeIn(duration: 300.ms),
                CustomPaint(size: const Size(18, 10), painter: _PointerPainter()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = const Color(0xFFE5E5E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

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