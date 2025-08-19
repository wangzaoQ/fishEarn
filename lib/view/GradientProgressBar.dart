import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlossyCapsuleProgressBar extends StatelessWidget {
  final double progress;            // 0..1
  final double height;              // 条高度
  final EdgeInsets padding;         // 进度层相对底轨的内边距
  final List<BoxShadow> shadow;     // 外部阴影（可选）

  const GlossyCapsuleProgressBar({
    super.key,
    required this.progress,
    this.height = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    this.shadow = const [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 6,
        offset: Offset(0, 2),
      )
    ],
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final outerRadius = BorderRadius.circular(height / 2);
    final innerHeight = height - padding.vertical;
    final innerRadius = BorderRadius.circular(innerHeight / 2);

    return SizedBox(
      height: height,
      width: 242.w,
      child: DecoratedBox(

        decoration: BoxDecoration(
          borderRadius: outerRadius,
          boxShadow: shadow,
        ),
        child: ClipRRect(
          borderRadius: outerRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset("assets/images/bg_game_progress1.webp",fit: BoxFit.cover,),
              // 顶部整体高光（柔和）
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.35, 0.5],
                    colors: [
                      Colors.white.withOpacity(0.55),
                      Colors.white.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // 内边距 + 进度填充层
              Padding(
                padding: padding,
                child: ClipRRect(
                  borderRadius: innerRadius,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: clamped,
                      alignment: Alignment.centerLeft,
                      child: _GlossyFill(height: innerHeight),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlossyFill extends StatelessWidget {
  final double height;
  const _GlossyFill({required this.height});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 主渐变：黄绿 -> 深绿
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFB7FF4A),
                Color(0xFF2DAE1B),
              ],
            ),
          ),
        ),
        // 中段加深（营造“压线”质感）
        Positioned.fill(
          top: height * 0.22,
          bottom: height * 0.22,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF63C926),
                  Color(0xFF2F9E1B),
                ],
              ),
            ),
          ),
        ),
        // 顶部高光
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.32, 0.55],
              colors: [
                Colors.white.withOpacity(0.75),
                Colors.white.withOpacity(0.18),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // 底部暖反光
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                const Color(0xFFFFE65B).withOpacity(0.28),
              ],
            ),
          ),
        ),
      ],
    );
  }
}