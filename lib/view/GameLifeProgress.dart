import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class CustomProgress3 extends StatefulWidget {
  final double progress; // 0~1
  const CustomProgress3({Key? key, required this.progress}) : super(key: key);

  @override
  State<CustomProgress3> createState() => _CustomProgress3State();
}

class _CustomProgress3State extends State<CustomProgress3>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0, end: widget.progress)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant CustomProgress3 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress.clamp(0, 1),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = 105.h;
    final double width = 19.w;
    final borderRadius = BorderRadius.circular(width / 2);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Image.asset(
            "assets/images/bg_fish_progress.webp",
            width: double.infinity,
            height: height,
            fit: BoxFit.fill,
          ),
          Padding(
            padding: EdgeInsets.all(3.h),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: _animation.value.clamp(0, 1),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C2711),
                      borderRadius: borderRadius,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

