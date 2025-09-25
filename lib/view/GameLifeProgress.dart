import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
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
    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant CustomProgress3 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation =
          Tween<double>(
            begin: _animation.value,
            end: widget.progress.clamp(0, 1),
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );

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
    var life = GameManager.instance.getLifeColor(LocalCacheUtils.getGameData().life);
    return SizedBox(
      width: 19.w,
      height: height,
      child: Stack(
        children: [
          Stack(
            children: [
              Image.asset(
                "assets/images/bg_game_life.png",
                width: width,
                height: height,
              ),

              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 11.w,
                  height: 97.h,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Align(
                        alignment: Alignment.bottomCenter, // 从底部对齐
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(width / 2),
                          child: Container(
                            width: width,
                            height: height * _animation.value.clamp(0, 1),
                            color: Color(life),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
