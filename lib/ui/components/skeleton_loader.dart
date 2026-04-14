import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key, required this.child});

  final Widget child;

  static Widget card({double height = 120, double radius = 20}) {
    return _SkeletonBox(height: height, width: double.infinity, radius: radius);
  }

  static Widget text({double width = 120}) {
    return _SkeletonBox(height: 12, width: width, radius: 999);
  }

  static Widget circle({double size = 40}) {
    return _SkeletonBox(height: size, width: size, radius: size / 2);
  }

  static Widget lessonCard() {
    return Column(
      children: [
        _SkeletonBox(height: 110, width: double.infinity, radius: 24),
        const SizedBox(height: 12),
      ],
    );
  }

  static Widget roadmapPhase() {
    return Column(
      children: [
        _SkeletonBox(height: 96, width: double.infinity, radius: 20),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => child;
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, required this.width, required this.radius});

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEEEEEE),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
