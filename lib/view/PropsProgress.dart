import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropsProgress extends StatelessWidget {
  final double progress; // 0~1
  final Color backgroundColor;
  final Color progressColor;

  const PropsProgress({
    Key? key,
    required this.progress,
    this.backgroundColor = const Color(0x8C000000),
    this.progressColor = const Color(0xFFE5452D),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0).toDouble();

    return Container(
      width: 50.w,
      height: 10.h,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(1), // 进度条与背景保持 2 的间距
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0), // 比外层小 2，保持圆角一致
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: (50.w) * clampedProgress, // 减去左右 padding 共 4
            height: double.infinity,
            decoration: BoxDecoration(
              color: progressColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
