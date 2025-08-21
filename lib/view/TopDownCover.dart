import 'package:flutter/material.dart';
class TopDownCover extends StatelessWidget {
  const TopDownCover({
    super.key,
    required this.asset,
    required this.cover, // 0~1
    required this.width,
    required this.height,
    this.coverColor = const Color(0xB35B2E00),
    this.fit = BoxFit.fill,
  });

  final String asset;
  final double cover;
  final double width;
  final double height;
  final Color coverColor;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final clamp = cover.clamp(0.0, 1.0);
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(asset, fit: fit),
          Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              alignment: Alignment.topCenter,
              heightFactor: clamp,
              child: Image.asset(
                asset,
                fit: fit,
                color: coverColor,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}