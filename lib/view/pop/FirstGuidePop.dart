import 'package:fish_earn/task/RewardManager.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/ClickManager.dart';

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
  late AnimationController _fadeAllController;
  late Animation<double> _fade1;
  late Animation<double> _fade2;
  late Animation<double> _fade3;

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

    _fadeAllController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _fade1 = CurvedAnimation(
      parent: _fadeAllController,
      curve: const Interval(0.0, 0.33, curve: Curves.easeOut),
    );
    _fade2 = CurvedAnimation(
      parent: _fadeAllController,
      curve: const Interval(0.33, 0.66, curve: Curves.easeOut),
    );
    _fade3 = CurvedAnimation(
      parent: _fadeAllController,
      curve: const Interval(0.66, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (!ClickManager.canClick(context: context)) return;
        Navigator.pop(context);
      },
      child: Stack(
        children: [
          // 第 1 步：
          FadeTransition(
            opacity: _fade1,
            child: Positioned(
              child: SizedBox(
                width: 375.w,
                height: 348.h,
                child: Stack(
                  children: [
                    Positioned(
                      top: 72.h,
                      left: 52.w,
                      right: 52.w,
                      child: Image.asset(
                        "assets/images/ic_guide1_title.webp",
                        width: double.infinity,
                        height: 63.h,
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
                                showText:
                                    "+\$${RewardManager.instance.get2LevelCoin()}/s",
                                fillColor: Color(0xFFF4FF72),
                                strokeWidth: 1.w,
                                strokeColor: Color(0xFF9B4801),
                                fontSize: 22.sp,
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
                                showText:
                                    "+\$${RewardManager.instance.get3LevelCoin()}/s",
                                fillColor: Color(0xFFF4FF72),
                                strokeWidth: 1.w,
                                strokeColor: Color(0xFF9B4801),
                                fontSize: 22.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 第 2 步：上方背景
          FadeTransition(
            opacity: _fade2,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsetsGeometry.only(top: 347.h),
                child: Image.asset(
                  "assets/images/bg_guide1_center.webp",
                  width: 320.w,
                ),
              ),
            ),
          ),

          // 第 3 步：底部背景
          FadeTransition(
            opacity: _fade3,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsetsGeometry.only(bottom: 130.h),
                child: SizedBox(
                  width: 355.w,
                  height: 169.h,
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        child: Image.asset(
                          "assets/images/bg_guide1_bottom.webp",
                          width: 355.w,
                          height: 169.h,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(bottom: 30.h),
                          child: Image.asset(
                            "assets/images/ic_first_guide_arrow.webp",
                            width: 61.w,
                            height: 36.h,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(alignment: Alignment.bottomCenter,child: Padding(padding: EdgeInsetsGeometry.only(bottom: 70.h),child: CupertinoButton(
            onPressed: () {
              if (!ClickManager.canClick(context: context)) return;
              Navigator.pop(context);
            },
            child: Text(
            "Next",
              style: TextStyle(
                fontSize: 20.sp,
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
                fontFamily: "AHV",
                decoration: TextDecoration.underline,
                // ✅ 下划线
                decorationColor: Color(0xBFFFFFFF),
                // 可选：自定义下划线颜色
                decorationThickness: 1.h,
              ),
            ),
          )),)
        ],
      ),
    );
  }
}
