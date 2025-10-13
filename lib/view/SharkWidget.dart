import 'package:flutter/material.dart';

class SharkWidget extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;
  final double top;
  final Duration moveDuration;
  final Duration fadeDuration;
  final Curve moveCurve;
  final Curve fadeCurve;

  const SharkWidget({
    Key? key,
    required this.imagePath,
    required this.width,
    required this.height,
    this.top = 100,
    this.moveDuration = const Duration(seconds: 2),
    this.fadeDuration = const Duration(seconds: 1),
    this.moveCurve = Curves.easeOut,
    this.fadeCurve = Curves.easeIn,
  }) : super(key: key);

  @override
  _SharkWidgetState createState() => _SharkWidgetState();
}

class _SharkWidgetState extends State<SharkWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rightAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    final total = widget.moveDuration + widget.fadeDuration;
    _controller = AnimationController(vsync: this, duration: total);
    final moveEnd = widget.moveDuration.inMilliseconds / total.inMilliseconds;

    _rightAnim = Tween<double>(
      begin: -widget.width,
      end: -widget.width / 2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, moveEnd, curve: widget.moveCurve),
      ),
    );

    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(moveEnd, 1.0, curve: widget.fadeCurve),
      ),
    );

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
      builder: (context, child) {
        return Positioned(
          top: widget.top, // ✅ 现在可以正常生效
          right: _rightAnim.value,
          child: Opacity(
            opacity: _fadeAnim.value,
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: Image.asset(widget.imagePath, fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }
}
