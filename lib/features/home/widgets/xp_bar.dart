import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class XpBar extends StatelessWidget {
  const XpBar({super.key, required this.totalXP});

  final int totalXP;

  @override
  Widget build(BuildContext context) {
    final threshold = totalXP <= 200 ? 200 : totalXP <= 500 ? 500 : 800;
    final percent = (totalXP / threshold).clamp(0, 1).toDouble();

    return LinearPercentIndicator(
      lineHeight: 14,
      percent: percent,
      barRadius: const Radius.circular(8),
      progressColor: Colors.amber,
      backgroundColor: Colors.black12,
      center: Text('$totalXP XP', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
