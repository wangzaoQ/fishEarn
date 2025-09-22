import 'package:flutter/material.dart';

/// 顶部圆角 + 底部向上凹遮挡
class TopRoundedBottomInverted extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double topRadius; // 顶部圆角
  final double bottomDepth; // 底部凹弧深度

  const TopRoundedBottomInverted({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    this.topRadius = 6.0,
    this.bottomDepth = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TopRoundedBottomInvertedClipper(topRadius, bottomDepth),
      child: Container(
        width: width,
        height: height,
        color: color,
      ),
    );
  }
}

class _TopRoundedBottomInvertedClipper extends CustomClipper<Path> {
  final double topRadius;
  final double bottomDepth;

  _TopRoundedBottomInvertedClipper(this.topRadius, this.bottomDepth);

  @override
  Path getClip(Size size) {
    final Path path = Path();

    // 左上圆角
    path.moveTo(0, topRadius);
    path.quadraticBezierTo(0, 0, topRadius, 0);

    // 顶部直线到右上圆角
    path.lineTo(size.width - topRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, topRadius);

    // 右侧直线到底部弧起点
    path.lineTo(size.width, size.height - bottomDepth);

    // 底部向上凹弧（控制点在上方形成 U 型凹）
    path.quadraticBezierTo(
      size.width / 2, size.height - bottomDepth * 2, // 控制点
      0, size.height - bottomDepth,                  // 左底弧终点
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
