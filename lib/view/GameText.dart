import 'package:flutter/material.dart';

class GameText extends StatelessWidget {
  GameText({
    super.key,
    required this.showText,
    this.fontSize = 22,
    this.strokeWidth = 3,
    this.fillColor = Colors.white,
    this.strokeColor = const Color(0xFF8B4513), // 棕色描边
    this.shadowColor = const Color(0xFF8B4513),
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.background,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  final double fontSize;
  final double strokeWidth;
  final Color fillColor;
  final Color strokeColor;
  final Color shadowColor;
  final EdgeInsets padding;
  final Decoration? background; // 可放渐变/纯色背景
  final BorderRadius borderRadius;
  final String showText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: background ??
          BoxDecoration(
            color: Colors.transparent,
            borderRadius: borderRadius,
          ),
      child: Stack(
        children: [
          // 描边层
          Text(
            showText,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              fontFamily: "AHV",
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..color = strokeColor,
              shadows: [
                // 底部阴影：大、模糊
                Shadow(
                  color: shadowColor.withOpacity(0.7),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
                // 顶部阴影：小、淡
                Shadow(
                  color: shadowColor.withOpacity(0.25),
                  offset: const Offset(0, -1),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
          // 填充层
          Text(
            showText,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              fontFamily: "AHV",
              color: fillColor,
              shadows: [
                Shadow(
                  color: shadowColor.withOpacity(0.6),
                  offset: const Offset(0, 2),
                  blurRadius: 3,
                ),
                Shadow(
                  color: shadowColor.withOpacity(0.2),
                  offset: const Offset(0, -1),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
