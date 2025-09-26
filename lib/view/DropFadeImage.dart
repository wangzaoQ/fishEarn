import 'package:flutter/material.dart';

class DropFadeImage extends StatefulWidget {
  final Widget child;
  final double startY;
  final double endY;
  final Duration duration;

  const DropFadeImage({
    super.key,
    required this.child,
    this.startY = 0,
    this.endY = 300,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<DropFadeImage> createState() => _DropFadeImageState();
}

class _DropFadeImageState extends State<DropFadeImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _positionAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _positionAnim = Tween<double>(begin: widget.startY, end: widget.endY)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnim = Tween<double>(begin: 1, end: 0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // 每次创建就自动播放动画
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, _positionAnim.value),
          child: Opacity(
            opacity: _opacityAnim.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
