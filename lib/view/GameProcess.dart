import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/EventConfig.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/data/GameData.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:fish_earn/view/pop/BasePopView.dart';
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
import '../utils/GlobalTimerManager.dart';
import '../utils/NetWorkManager.dart';
import '../utils/ad/ADEnum.dart';
import '../utils/ad/ADShowManager.dart';
import '../utils/net/EventManager.dart';
import 'GradientProgressBar.dart';
import 'ProgressClipper.dart';

class GameProgress extends StatefulWidget {
  final double progress; // 0~1
  final void Function(int result) onConfirm; // 👈 改成支持参数的函数

  const GameProgress({
    Key? key,
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

  var allowClickAd = true;

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
        GlobalTimerManager().cancelTimer();
        GameManager.instance.pauseMovement();
        showMarkNew3();
      }
    });
    gameData = LocalCacheUtils.getGameData();
  }

  var first1_2 = true;
  var first2_3 = true;

  late GameData gameData;


  @override
  void didUpdateWidget(covariant GameProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _oldProgress = widget.progress;
    }
    gameData = LocalCacheUtils.getGameData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  var cacheShowMoney = true;
  var cacheType = 0;

  var firstShowWithdraw = true;

  @override
  Widget build(BuildContext context) {
    final double progressHeight = 25.h; // 进度条高度
    final BorderRadius borderRadius = BorderRadius.circular(progressHeight / 2);
    if (gameData.level == 3) {
      cacheShowMoney = LocalCacheUtils.getBool(
        LocalCacheConfig.cacheShowMoney,
        defaultValue: true,
      );
      cacheType = LocalCacheUtils.getInt(
        LocalCacheConfig.cacheType,
        defaultValue: 0,
      );
      if(firstShowWithdraw){
        firstShowWithdraw =false;
        EventManager.instance.postEvent(EventConfig.home_withdraw);
      }
    }
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
            child: gameData.level == 3
                ? SizedBox(
                    width: double.infinity,
                    height: 127.h,
                    child: Stack(
                      children: [
                        Image.asset(
                          cacheType == 0 ? "assets/images/bg_home_cash_paypal.webp" : "assets/images/bg_home_cash.webp",
                          width: double.infinity,
                          height: 127.h,
                          fit: BoxFit.fill,
                        ),
                        Positioned(
                          left: 22.w,
                          top: 10.h,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero, // 去掉默认内边距
                            pressedOpacity: 0.7,
                            child: SizedBox(
                              width: 115.w,
                              height: 27.h,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(cacheType == 0?0xFF2F5FC5:0xFF44B04C),
                                  // #012169 的十六进制写法
                                  borderRadius: BorderRadius.circular(
                                    14,
                                  ), // 圆角 5dp
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    cacheType == 0 ?
                                    Image.asset(
                                      width: 70.w,
                                      height: 17.h,
                                      "assets/images/ic_cash_paypal.webp",
                                    ):Image.asset(
                                      width: 77.w,
                                      height: 20.h,
                                      "assets/images/ic_cash_cash.webp",
                                    ),
                                    Image.asset(
                                      width: 15.w,
                                      height: 10.h,
                                      "assets/images/ic_home_cash_change.webp",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                if (cacheType == 0) {
                                  cacheType = 1;
                                } else {
                                  cacheType = 0;
                                }
                                LocalCacheUtils.putInt(
                                  LocalCacheConfig.cacheType,
                                  cacheType,
                                );
                              });
                            },
                          ),
                        ),
                        // Positioned(
                        //   top: 27.h,
                        //   right: 128.w,
                        //   child: SizedBox(
                        //     width: 17.w,
                        //     height: 11.h,
                        //     child: CupertinoButton(
                        //       padding: EdgeInsets.zero,
                        //       pressedOpacity: 0.7,
                        //       child: Image.asset("assets/images/ic_eye.webp"),
                        //       onPressed: () {
                        //         setState(() {
                        //           cacheShowMoney = !cacheShowMoney;
                        //           LocalCacheUtils.putBool(
                        //             LocalCacheConfig.cacheShowMoney,
                        //             !cacheShowMoney,
                        //           );
                        //         });
                        //       },
                        //     ),
                        //   ),
                        // ),
                        Positioned(
                          top: 10.h,
                          left: 262.w,
                          child: ValueListenableBuilder<double>(
                            valueListenable: moneyListener,
                            builder: (_, value, __) {
                              gameData = LocalCacheUtils.getGameData();

                              return GameText(
                                showText: cacheShowMoney
                                    ? "\$${GameManager.instance.getCoinShow2(gameData.coin)}"
                                    : "****",
                                fontSize: 28.sp,
                                fillColor: Colors.white,
                                strokeColor: Colors.black,
                                strokeWidth: 1.w,
                              ); // 只重建这一小块
                            },
                          ),
                        ),
                        Positioned(
                          right: 21.w,
                          top: 50.h,
                          child: SizedBox(
                            width: 102.w,
                            height: 30.h,
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              pressedOpacity: 0.7,
                              child: Stack(
                                children: [
                                  Image.asset(
                                    width: 102.w,
                                    height: 30.h,
                                    "assets/images/bg_confirm.webp",
                                    fit: BoxFit.fill,
                                  ),
                                  Center(
                                    child: Text(
                                      "app_withdraw".tr(),
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Color(0xFF185F11),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                if (!ClickManager.canClick(context: context)) return;
                                EventManager.instance.postEvent(EventConfig.home_withdraw_c);
                                setState(() {
                                  widget.onConfirm(10);
                                });
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20.w,
                          top: 47.h,
                          right: 166.w,
                          child: Wrap(
                            alignment: WrapAlignment.center, // 居中对齐
                            runSpacing: -4, // 换行后两行之间的垂直间距
                            children: [
                              GameText(
                                showText: 'Your First ',
                                fontSize: 16.sp,
                                fillColor: Colors.white,
                                strokeWidth: 1.w,
                                strokeColor: Colors.black,
                              ),
                              GameText(
                                showText: '\$500',
                                fontSize: 16.sp,
                                fillColor: Color(0xFF5CFF40),
                                strokeWidth: 1.w,
                                strokeColor: Colors.black,
                              ),
                              GameText(
                                showText: ' Today! I\'ll Guide You!',
                                fontSize: 16.sp,
                                fillColor: Colors.white,
                                strokeWidth: 1.w,
                                strokeColor: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 90.h,
                          left: 22.w,
                          right: 22.w,
                          child: SizedBox(
                            height: 25.h,
                            child: ValueListenableBuilder<double>(
                              valueListenable: moneyListener,
                              builder: (_, value, __) {
                                gameData = LocalCacheUtils.getGameData();
                                var current = GameManager.instance.getCoinShow2(
                                  gameData.coin,
                                );
                                var All = 500;
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final progress = (current / All).clamp(0.0, 1.0); // 限制范围 0~1
                                    final clipWidth = (constraints.maxWidth - 4) * progress;

                                    return Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // 背景条
                                        Image.asset(
                                          "assets/images/bg_home_cash_progress.webp",
                                          height: 25.h,
                                          fit: BoxFit.fill,
                                        ),

                                        // 前景进度条
                                        Padding(
                                          padding: EdgeInsets.all(4.h),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: ClipRect(
                                              clipper: ProgressClipper(width: clipWidth),
                                              child: FittedBox(
                                                fit: BoxFit.none, // 不缩放图片
                                                alignment: Alignment.centerLeft, // 从左对齐
                                                child: Image.asset(
                                                  "assets/images/bg_home_cash_progress2.webp",
                                                  height: 25.h,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                                ; // 只重建这一小块
                              },
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsetsGeometry.only(top: 85.h),
                            child: SizedBox(
                              width: 100.w,
                              height: 25.h,
                              child: ValueListenableBuilder<double>(
                                valueListenable: moneyListener,
                                builder: (_, value, __) {
                                  gameData = LocalCacheUtils.getGameData();

                                  var current = GameManager.instance
                                      .getCoinShow2(gameData.coin);
                                  var All = 500;
                                  return Row(
                                    children: [
                                      GameText(
                                        showText: "\$${current}",
                                        fillColor: Colors.white,
                                        strokeColor: Colors.black,
                                        strokeWidth: 1.w,
                                      ),
                                      GameText(
                                        showText: "/${All}",
                                        fillColor: Color(0xFF5CFF40),
                                        strokeColor: Colors.black,
                                        strokeWidth: 1.w,
                                      ),
                                    ],
                                  ); // 只重建这一小块
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
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
                              tween: Tween(
                                begin: _oldProgress,
                                end: widget.progress,
                              ),
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
                                          gameData.level == 1)
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
                              if (!ClickManager.canClick(context: context)) return;
                              EventManager.instance.postEvent(EventConfig.home_growing_c,params: {"type": gameData.level});
                              if (gameData.level == 1 &&
                                  widget.progress == 0.5) {
                                var userData = LocalCacheUtils.getUserData();
                                var result = await PopManager().show(
                                  context: context,
                                  child: LevelUp1_2(),
                                );
                                if (!userData.new3) {
                                  if (result == 1) {
                                    toLevel2(context);
                                  }
                                }else{
                                  if (result == 1) {
                                    if(!allowClickAd)return;
                                    allowClickAd = false;
                                    ADShowManager(adEnum:ADEnum.rewardedAD,tag:"reward",result: (type,hasValue){
                                      allowClickAd = true;
                                      if(hasValue){
                                        toLevel2(context);
                                      }
                                    }).showScreenAD(EventConfig.fixrn_grow_rv,awaitLoading: true);
                                  }
                                }
                              }
                            },
                          ),
                        ),
                        gameData.level == 1
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
                                  (widget.progress == 1 &&
                                          gameData.level == 2)
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
                              if (!ClickManager.canClick(context: context)) return;
                              EventManager.instance.postEvent(EventConfig.home_growing_c,params: {"type": gameData.level});
                              GameManager.instance.pauseMovement();
                              if (gameData.level == 2 &&
                                  widget.progress == 1) {
                                var result = await PopManager().show(
                                  context: context,
                                  child: LevelUp2_3(),
                                );
                                if (result == 1) {
                                  gameData.level = 3;
                                  LocalCacheUtils.putGameData(gameData);
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
                        gameData.level == 2
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
    var userData = LocalCacheUtils.getUserData();
    gameData = LocalCacheUtils.getGameData();
    userData.new3 = false;
    LocalCacheUtils.putUserData(userData);
    gameData.level = 2;
    gameData.levelTime = GameConfig.time_2_3;
    LocalCacheUtils.putGameData(gameData);
    widget.onConfirm(2);
    await PopManager().show(context: context, child: LevelPop1_2());
    gameData.coin += GameConfig.coin_1_2;
    LocalCacheUtils.putGameData(gameData);
    GameManager.instance.updateCoinToGame(gameData.coin);
    eventBus.fire(NotifyEvent(EventConfig.new4));
  }

  TutorialCoachMark? tutorialCoachMark;
  late List<TargetFocus> globalKeyNew3Keys;
  GlobalKey globalKeyNew3 = GlobalKey();

  void showMarkNew3() {
    EventManager.instance.postEvent(EventConfig.new_guide,params: {"pop_step": "pop3"});

    var userData = LocalCacheUtils.getUserData();
    userData.new2 = false;
    LocalCacheUtils.putUserData(userData);
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
              clipBehavior: Clip.none, // 防止溢出裁剪
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(0, 63.h, 0, 0),
                    child: Image.asset(
                      "assets/images/ic_fish_tips.webp",
                      width: 75.w,
                      height: 75.h,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(68.w, 74.h, 0, 0),
                    child: Container(
                      width: 268.w,
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      height: 74.h, // 让高度自适应文字
                      child: Stack(
                        children: [
                          Image.asset(
                            "assets/images/bg_level_up.webp",
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.fill,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(26.w, 0, 16.w, 0),
                            child: Center(
                              child: Text.rich(
                                TextSpan(
                                  text: "", // 默认样式
                                  style: TextStyle(
                                    fontSize: 14.sp,
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
      onFinish: () {
        EventManager.instance.postEvent(EventConfig.new_guide_c,params: {"pop_step": "pop3"});
        toLevel2(context);
      },
      onClickTarget: (target) {
        if (!ClickManager.canClick(context: context)) return;
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
