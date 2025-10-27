import 'package:fish_earn/task/RewardManager.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FirstGuidePop extends StatefulWidget {
  const FirstGuidePop({super.key});

  @override
  State<FirstGuidePop> createState() => _FirstGuidePopState();
}

class _FirstGuidePopState extends State<FirstGuidePop>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    // 时长 1 秒，周期性重复
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(); // 持续每秒执行一次

    // 向上平移（偏移单位是 FractionalOffset）
    _offsetAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.8), // 向上 0.25 高度（可调整）
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // 透明度从 1 -> 0
    _opacityAnim = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 12.w,
          right: 12.w,
          top: 73.h,
          bottom: 138.h,
          child: Image.asset(
            "assets/images/bg_guide_first.webp",
            width: 375.w,
            height: 812.h,
            fit: BoxFit.fill,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(bottom: 220.h),
            child: Image.asset(
              "assets/images/ic_paypal.webp",
              width: 72.w,
              height: 18.h,
            ),
          ),
        ),
        Positioned(
          top: 233.h,
          left: 25.w,
          child: Image.asset(
            "assets/images/ic_guide1_fish1.webp",
            width: 103.w,
            height: 103.h,
          ),
        ),
        Positioned(
          top: 198.h,
          left: 125.w,
          child: Image.asset(
            "assets/images/ic_guide1_fish2.webp",
            width: 103.w,
            height: 103.h,
          ),
        ),
        Positioned(
          top: 163.h,
          right: 27.w,
          child: Image.asset(
            "assets/images/ic_guide1_fish3.webp",
            width: 107.w,
            height: 114.h,
          ),
        ),
        Positioned(
          // 文字基点：放在图片上方（可根据需要微调）
          top: 185.h, // 举例：比图片上方 30.h
          left: 125.w, // 与图片左对齐
          child: SizedBox(
            width: 103.w, // 根据文字长度调整宽度
            child: Center(
              child: SlideTransition(
                position: _offsetAnim,
                child: FadeTransition(
                  opacity: _opacityAnim,
                  child: GameText(
                    showText: "+\$${RewardManager.instance.get2LevelCoin()}/s",
                    fillColor: Color(0xFFF4FF72),
                    strokeWidth: 1.w,
                    strokeColor: Color(0xFF9B4801),
                    fontSize: 28.sp,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          // 文字基点：放在图片上方（可根据需要微调）
          top: 150.h, // 举例：比图片上方 30.h
          right: 27.w, // 与图片左对齐
          child: SizedBox(
            width: 107.w, // 根据文字长度调整宽度
            child: Center(
              child: SlideTransition(
                position: _offsetAnim,
                child: FadeTransition(
                  opacity: _opacityAnim,
                  child: GameText(
                    showText: "+\$${RewardManager.instance.get3LevelCoin()}/s",
                    fillColor: Color(0xFFF4FF72),
                    strokeWidth: 1.w,
                    strokeColor: Color(0xFF9B4801),
                    fontSize: 28.sp,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
