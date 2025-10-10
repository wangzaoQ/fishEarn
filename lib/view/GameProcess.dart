import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/EventConfig.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/data/GameData.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:fish_earn/view/pop/CoinAnimalPop.dart';
import 'package:fish_earn/view/pop/LevelPop1_2.dart';
import 'package:fish_earn/view/pop/LevelPop2_3.dart';
import 'package:fish_earn/view/pop/LevelUp1_2.dart';
import 'package:fish_earn/view/pop/LevelUp2_3.dart';
import 'package:fish_earn/view/pop/PopManger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../config/GameConfig.dart';
import '../config/global.dart';
import '../event/NotifyEvent.dart';
import '../utils/AudioUtils.dart';
import '../utils/ClickManager.dart';
import '../utils/NetWorkManager.dart';
import 'GradientProgressBar.dart';

class GameProgress extends StatefulWidget {
  final double progress; // 0~1
  final GameData gameData; // 0~1
  final void Function(int result) onConfirm; // 👈 改成支持参数的函数

  const GameProgress({
    Key? key,
    required this.gameData,
    required this.progress,
    required this.onConfirm,
  }) : super(key: key);

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

    eventBus.on<NotifyEvent>().listen((event) {
      if (event.message == EventConfig.new3) {
        GameManager.instance.pauseMovement();
        showMarkNew3();
      }
    });
  }

  var first1_2 = true;
  var first2_3 = true;

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

    return PopScope(
      canPop: false, // 禁止默认返回
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (tutorialCoachMark?.isShowing ?? false) {
            // 自定义逻辑
            tutorialCoachMark?.skip(); // 关闭当前教程
          }
        }
      },
      child: Stack(
        children: [
          Positioned(
            left: 5.w,
            right: 5.w,
            child: SizedBox(
              key: globalKeyNew3,
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
                              GlossyCapsuleProgressBar(
                                progress: v,
                                height: 25.h,
                              ),
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
                            (widget.progress == 0.5 &&
                                    widget.gameData.level == 1)
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
                      ),
                      onPressed: () async {
                        AudioUtils().playClickAudio();
                        if (NetWorkManager().isNetError(context)) return;
                        if (!ClickManager.canClick()) return;
                        if (widget.gameData.level == 1 &&
                            widget.progress == 0.5) {
                          var userData = LocalCacheUtils.getUserData();
                          if (!userData.new3) {
                            var result = await PopManager().show(
                              context: context,
                              child: LevelUp1_2(),
                            );
                            if (result == 1) {
                              toLevel2(context);
                            }
                          }
                        }
                      },
                    ),
                  ),
                  widget.gameData.level == 1
                      ? Positioned(
                          left: 180.w,
                          top: 6.h,
                          child: SizedBox(
                            width: 58.w,
                            height: 27.h,
                            child: Stack(
                              children: [
                                Image.asset(
                                  "assets/images/bg_tips_level.webp",
                                  width: 58.w,
                                  height: 27.h,
                                  fit: BoxFit.fill,
                                ),
                                Positioned(
                                  left: 2.w,
                                  top: 1.h,
                                  child: Image.asset(
                                    "assets/images/ic_coin2.webp",
                                    width: 20.w,
                                    height: 20.h,
                                  ),
                                ),
                                Positioned(
                                  left: 22.w,
                                  top: 2.h,
                                  child: Text(
                                    "+\$${GameConfig.coin_1_2}",
                                    style: TextStyle(
                                      color: Color(0xFF561C3E),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
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
                      onPressed: () async {
                        AudioUtils().playClickAudio();
                        if (NetWorkManager().isNetError(context)) return;
                        if (!ClickManager.canClick()) return;
                        GameManager.instance.pauseMovement();
                        if (widget.gameData.level == 2 &&
                            widget.progress == 1) {
                          var result = await PopManager().show(
                            context: context,
                            child: LevelUp2_3(),
                          );
                          if (result == 1) {
                            widget.gameData.level = 3;
                            LocalCacheUtils.putGameData(widget.gameData);
                            widget.onConfirm(3);
                            await PopManager().show(
                              context: context,
                              child: LevelPop2_3(),
                            );
                          }
                        }
                        GameManager.instance.resumeMovement();
                      },
                    ),
                  ),
                  widget.gameData.level == 2
                      ? Positioned(
                    right: 30.w,
                    top: 6.h,
                    child: SizedBox(
                      width: 60.w,
                      height: 27.h,
                      child: Stack(
                        children: [
                          Image.asset(
                            "assets/images/bg_tips_level.webp",
                            width: 60.w,
                            height: 27.h,
                            fit: BoxFit.fill,
                          ),
                          Positioned(
                            left: 2.w,
                            top: 1.h,
                            child: Image.asset(
                              "assets/images/ic_coin2.webp",
                              width: 20.w,
                              height: 20.h,
                            ),
                          ),
                          Positioned(
                            left: 22.w,
                            top: 2.h,
                            child: Text(
                              "+\$${GameConfig.coin_2_3}",
                              style: TextStyle(
                                color: Color(0xFF561C3E),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : SizedBox.shrink(),
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
                  // widget.gameData.level == 2 && widget.progress == 1?SizedBox.shrink():
                  Positioned(
                    left: 110.w,
                    top: 55.h, // 在进度条下方一点
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      pressedOpacity: 0.7,
                      onPressed: null,
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> toLevel2(BuildContext context) async {
    widget.gameData.level = 2;
    widget.gameData.levelTime = GameConfig.time_2_3;
    LocalCacheUtils.putGameData(widget.gameData);
    widget.onConfirm(2);
    await PopManager().show(context: context, child: LevelPop1_2());
    GameManager.instance.resumeMovement();
    eventBus.fire(NotifyEvent(EventConfig.new4));
  }

  TutorialCoachMark? tutorialCoachMark;
  late List<TargetFocus> globalKeyNew3Keys;
  GlobalKey globalKeyNew3 = GlobalKey();

  void showMarkNew3() {
    globalKeyNew3Keys = [];
    globalKeyNew3Keys.add(
      TargetFocus(
        identify: "guide3",
        keyTarget: globalKeyNew3,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 12.0,
        // 圆角半径，自行调整
        contents: [
          TargetContent(
            align: ContentAlign.bottom, // 内容在高亮 widget 下方
            child: Stack(
              children: [
                SizedBox(
                  width: 268.w,
                  height: 74.h,
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/images/bg_level_up.webp",
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.fill,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 17.w, right: 8.w),
                        child: Center(
                          child: Text.rich(
                            TextSpan(
                              text: "", // 默认样式
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: "app_level_up_tips1".tr(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Color(0xFF651922),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: "app_level_up_tips2".tr(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Color(0xFF2C9814),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    tutorialCoachMark = TutorialCoachMark(
      targets: globalKeyNew3Keys,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: "",
      paddingFocus: 0,
      onFinish: () {},
      onClickTarget: (target) {
        AudioUtils().playClickAudio();
        toLevel2(context);
      },
    );
    tutorialCoachMark?.show(context: context);
  }

  //
  // void showMarkLevel2_3() {
  //   guideLevel2_3Keys = [];
  //   guideLevel2_3Keys.add(
  //     TargetFocus(
  //       identify: "guide2_3",
  //       keyTarget: globalKeyGuide2_3,
  //       alignSkip: Alignment.topRight,
  //       contents: [],
  //     ),
  //   );
  //   tutorialCoachMark = TutorialCoachMark(
  //     targets: guideLevel2_3Keys,
  //     colorShadow: Colors.black.withOpacity(0.8),
  //     textSkip: "",
  //     paddingFocus: 10,
  //     onFinish: () {},
  //     onClickTarget: (target) {},
  //   );
  //   tutorialCoachMark?.show(context: context);
  // }
}
