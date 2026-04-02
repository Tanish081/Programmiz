import 'package:flutter/material.dart';

class HeartIndicator extends StatelessWidget {
  const HeartIndicator({super.key, required this.lives});

  final int lives;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.favorite, color: Colors.red, size: 20),
        const SizedBox(width: 4),
        Text('$lives'),
      ],
    );
  }
}
