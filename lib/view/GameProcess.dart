import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/data/GameData.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/GameConfig.dart';
import 'GradientProgressBar.dart';

class GameProgress extends StatefulWidget {
  final double progress; // 0~1
  final GameData gameData; // 0~1
  final void Function(int result) onConfirm; // 👈 改成支持参数的函数

  const GameProgress({Key? key, required this.gameData, required this.progress,required this.onConfirm,})
    : super(key: key);

  @override
  State<GameProgress> createState() => _GameProgressState();
}

class _GameProgressState extends State<GameProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _oldProgress = 0;

  @override
  void initState() {
    super.initState();
    _oldProgress = widget.progress;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // 一圈时间
    )..repeat(); // 无限旋转
  }

  @override
  void didUpdateWidget(covariant GameProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _oldProgress = widget.progress;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progressHeight = 25.h; // 进度条高度
    final BorderRadius borderRadius = BorderRadius.circular(progressHeight / 2);

    return Stack(
      children: [
        Positioned(
          left: 5.w,
          right: 5.w,
          child: SizedBox(
            width: double.infinity,
            height: 100.h,
            child: Stack(
              children: [
                // 背景图
                Image.asset(
                  "assets/images/bg_game_process2.webp",
                  width: double.infinity,
                  height: 100.h,
                  fit: BoxFit.fill,
                ),
                // 进度条容器
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 33.h),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: _oldProgress, end: widget.progress),
                      duration: const Duration(milliseconds: 500),
                      builder: (_, v, __) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GlossyCapsuleProgressBar(progress: v, height: 25.h),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                //level 1
                Positioned(
                  left: 50.w,
                  top: 33.h,
                  child: Image.asset(
                    "assets/images/ic_game1.webp",
                    width: 38.w,
                    height: 21.h,
                  ),
                ),
                Positioned(
                  left: 50.w,
                  top: 55.h,
                  child: GameText(
                    showText: "LV 1",
                    fontSize: 16.sp,
                    strokeColor: Color(0xFF9B4801),
                  ),
                ),
                //level 2
                Positioned(
                  left: 150.w,
                  top: 10.h,
                  child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      pressedOpacity: 0.7,
                      child: SizedBox(
                    width: 68.w,
                    height: 68.h,
                    child: Stack(
                      children: [
                        (widget.progress == 0.5 && widget.gameData.level == 1)
                            ? RotationTransition(
                          turns: _controller,
                          child: Image.asset(
                            "assets/images/bg_game_progress.webp",
                          ),
                        )
                            : SizedBox.shrink(),
                        Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            "assets/images/ic_game2.webp",
                            width: 43.w,
                            height: 30.h,
                          ),
                        ),
                      ],
                    ),
                  ), onPressed: (){
                    if (widget.gameData.level == 1 &&
                        widget.progress == 0.5) {
                      widget.gameData.level = 2;
                      widget.gameData.levelTime = GameConfig.time_2_3;
                      LocalCacheUtils.putGameData(widget.gameData);
                      widget.onConfirm(2);
                    }
                  })
                ),
                Positioned(
                  left: 160.w,
                  top: 55.h,
                  child: GameText(
                    showText: "LV 2",
                    fontSize: 16.sp,
                    fillColor: Color(0xFFFFEF50),
                    strokeColor: Color(0xFF9B4801),
                  ),
                ),
                //level 3
                Positioned(
                  right: 50.w,
                  top: 10.h,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    pressedOpacity: 0.7,
                    child: SizedBox(
                      width: 68.w,
                      height: 68.h,
                      child: Stack(
                        children: [
                          (widget.progress == 1 && widget.gameData.level == 2)
                              ? RotationTransition(
                                  turns: _controller,
                                  child: Image.asset(
                                    "assets/images/bg_game_progress.webp",
                                  ),
                                )
                              : SizedBox.shrink(),
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              "assets/images/ic_game3.webp",
                              width: 55.w,
                              height: 36.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      widget.onConfirm(3);

                      if (widget.gameData.level == 2 &&
                          widget.progress == 1) {
                        widget.gameData.level = 3;
                        LocalCacheUtils.putGameData(widget.gameData);
                        widget.onConfirm(3);
                      }
                    },
                  ),
                ),
                Positioned(
                  right: 60.w,
                  top: 55.h,
                  child: GameText(
                    showText: "LV 3",
                    fillColor: Color(0xFFFFEF50),
                    fontSize: 16.sp,
                    strokeColor: Color(0xFF9B4801),
                  ),
                ),
                Positioned(
                  left: 110.w,
                  top: 55.h, // 在进度条下方一点
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    pressedOpacity: 0.7,
                    child: SizedBox(
                      width: 46.w,
                      height: 25.h,
                      child: Stack(
                        children: [
                          Image.asset(
                            "assets/images/ic_up_arrow.webp",
                            width: 23.w,
                            height: 23.h,
                          ),
                          Positioned(
                            left: 15.w,
                            bottom: 0.h,
                            child: GameText(
                              showText: "app_up".tr(),
                              fontSize: 12.sp,
                              strokeColor: Color(0xFF000000),
                            ),
                          ),
                          Positioned(
                            left: 13.w,
                            child: Image.asset(
                              "assets/images/ic_ad_tips.webp",
                              width: 15.w,
                              height: 15.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
