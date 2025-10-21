import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class ArrowWidget extends StatefulWidget {
  final double progress; // 0~1
  const ArrowWidget({Key? key,required this.progress,}) : super(key: key);

  @override
  State<ArrowWidget> createState() => _ArrowWidgetState();
}

class _ArrowWidgetState extends State<ArrowWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  bool _visible = true; // 🔹 控制是否显示

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(vsync: this);
    // 🔹 3 秒后让它隐藏
    // Future.delayed(const Duration(seconds: 3), () {
    //   if (mounted) {
    //     setState(() {
    //       _visible = false;
    //     });
    //   }
    // });
    _visible = widget.progress>=1?true:false;
  }


  @override
  void didUpdateWidget(covariant ArrowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _visible = widget.progress>=1?true:false;
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink(); // 🔹 隐藏
    return Lottie.asset(
      width: 100.w, height: 100.h,
      'assets/animations1/arrow.json',
      controller: _lottieController,
      onLoaded: (composition) {
        _lottieController
          ..duration = composition.duration
          ..repeat(); // 🔁 循环播放
      },
    );
  }
}