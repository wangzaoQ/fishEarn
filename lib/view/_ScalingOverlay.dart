import 'package:flutter/cupertino.dart';

class ScalingOverlay extends StatefulWidget {
  final Widget child;
  const ScalingOverlay({required this.child});

  @override
  State<ScalingOverlay> createState() => _ScalingOverlayState();
}

class _ScalingOverlayState extends State<ScalingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // 每次缩放 1 秒
    );

    _scale = Tween<double>(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    int count = 0;
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        count++;
        if (count < 5) {
          _controller.reverse();
        }
      } else if (status == AnimationStatus.dismissed && count < 5) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}
