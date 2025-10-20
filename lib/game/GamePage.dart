import 'dart:async';
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/cash/CashMain.dart';
import 'package:fish_earn/config/EventConfig.dart';
import 'package:fish_earn/config/GameConfig.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/task/TaskManager.dart';
import 'package:fish_earn/utils/AudioUtils.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/GlobalTimerManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/utils/NetWorkManager.dart';
import 'package:fish_earn/view/DropFadeImage.dart';
import 'package:fish_earn/view/GameProcess.dart';
import 'package:fish_earn/view/SharkWidget.dart';
import 'package:fish_earn/view/bubbleWidget.dart';
import 'package:fish_earn/view/pop/CashProcessPop.dart';
import 'package:fish_earn/view/pop/CoinAnimalPop.dart';
import 'package:fish_earn/view/pop/GameAward.dart';
import 'package:fish_earn/view/pop/GameFailPop.dart';
import 'package:fish_earn/view/pop/GamePearlPop.dart';
import 'package:fish_earn/view/pop/LevelPop1_2.dart';
import 'package:fish_earn/view/pop/NoPearlPop.dart';
import 'package:fish_earn/view/pop/PopManger.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../config/global.dart';
import '../data/GameData.dart';
import '../data/UserData.dart';
import '../event/NotifyEvent.dart';
import '../model/GameViewModel.dart';
import '../utils/ArrowOverlay.dart';
import '../utils/ClickManager.dart';
import '../utils/LogUtils.dart';
import '../view/GameLifeProgress.dart';
import '../view/GameText.dart';
import '../view/PropsProgress.dart';
import '../view/pop/BasePopView.dart';
import '../view/pop/LevelPop2_3.dart';
import '../view/pop/PropsAwardPop.dart';
import '../view/pop/SettingPop.dart';
import 'AnimalGameHolder.dart';
import 'ArrowWidget.dart';
import 'GameLifePage.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late GameData gameData;
  late double progress;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  var TAG = "GamePage";

  //生命相关
  var cutTime = 0;

  //道具相关
  var propsTime = 0;
  var aliveTime = 0;
  Timer? _timer = null;

  //第一次展示危险提示
  var firstShowProtectKey = true;

  //展示金币泡泡
  var showCoinBubbles = true;
  var showFoodBubbles = true;
  var showPearlBubbles1 = true;
  var showPearlBubbles2 = false;

  late UserData userData;

  int getCutTime() {
    return GameConfig.lifeDecreaseInterval;
  }

  int getProtectTime() {
    return GameConfig.protectDuration;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ✅ 注册

    AudioUtils().initTempQueue();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    firstShowProtectKey = LocalCacheUtils.getBool(
      LocalCacheConfig.firstShowProtectKey,
      defaultValue: true,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocalCacheUtils.putBool(
        LocalCacheConfig.firstLogin,
        false
      );
      registerTimer();
      if (userData.new1 ||
          userData.new2 ||
          userData.new3 ||
          userData.new4 ||
          userData.new5) {
        if (userData.new1) {
          showMarkNew1();
        } else if (userData.new2) {
          showMarkNew2();
        }else if(userData.new3){
          eventBus.fire(NotifyEvent(EventConfig.new3));
        }else if(userData.new4){
          eventBus.fire(NotifyEvent(EventConfig.new4));
        }else if(userData.new5){
          showMarkNew5();
        }else if(userData.new6 || userData.new7){
          toCashMain(context);
        }
      }
      // TaskManager.instance.addTask("login");
    });
    eventBus.on<NotifyEvent>().listen((event) {
      if (event.message == EventConfig.new4) {
        GameManager.instance.pauseMovement();
        setState(() {
          globalShowDanger2 = true;
        });
        showMarkNew4();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ✅ 记得移除
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    gameData = LocalCacheUtils.getGameData();
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
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/bg_game.webp",
                fit: BoxFit.cover,
              ),
            ),
            // top bar
            //鱼生命进度
            gameData.level == 1
                ? SizedBox.shrink()
                : Positioned(top: 310.h, left: 32.w, child: GameLifePage()),
            //鱼动画
            buildAnimal(),
            buildFood(),

            buildShark(),
            Positioned(
              top: 43.h,
              left: 8.w,
              right: 0,
              child: SizedBox(
                width: double.infinity,
                height: 45.h,
                child: Stack(
                  children: [
                    Positioned(
                      right: 15.w,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        pressedOpacity: 0.7,
                        child: Image.asset(
                          "assets/images/ic_setting.webp",
                          width: 45.w,
                          height: 45.h,
                        ),
                        onPressed: () async {
                          AudioUtils().playClickAudio();
                          var result = await PopManager().show(
                            context: context,
                            child: SettingPop(),
                          );
                          if (result == 1) {
                            //联系我们
                          } else if (result == 0) {
                            //隐私
                          }
                          if (!ClickManager.canClick(context: context)) return;
                          PopManager().show(context: context,
                              child: CashProcessPop(money: 800,));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //progress
            Padding(
              padding: EdgeInsetsGeometry.only(top: 94.h),
              child: Align(
                alignment: Alignment.topCenter,
                child: RepaintBoundary(
                  child: ValueListenableBuilder<double>(
                    valueListenable: globalTimeListener,
                    builder: (_, value, __) {
                      return GameProgress(
                        gameData: gameData,
                        progress: value,
                        onConfirm: (result) {
                          setState(() {});
                        },
                      ); // 只重建这一小块
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                width: double.infinity,
                height: 110.h,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        "assets/images/bg_game_bottom.webp",
                        width: double.infinity,
                        height: 76.h,
                        fit: BoxFit.fill,
                      ),
                    ),
                    // 其他内容
                    Align(
                      alignment: Alignment.center,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        pressedOpacity: 0.7,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            key: globalGuideNew1,
                            "assets/images/ic_play.webp",
                            height: 109.h,
                            width: 197.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                        onPressed: () {
                          clickFood();
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsetsGeometry.only(bottom: 12.h),
                        child: Container(
                          width: 36.w,
                          height: 18.h,
                          decoration: BoxDecoration(
                            color: const Color(0x8C000000),
                            // #8C000000 (alpha first in Flutter)
                            borderRadius: BorderRadius.circular(11.0), // 11dp
                          ),
                          child: Center(
                            child: Text(
                              "${gameData.foodCount}",
                              style: TextStyle(
                                color: Color(0xFFF4FF72),
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16.w,
                      bottom: 5.h,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        pressedOpacity: 0.7,
                        child: Image.asset(
                          "assets/images/ic_pearl.webp",
                          width: 67.w,
                          height: 67.h,
                        ),
                        onPressed: () async {
                          if (!ClickManager.canClick(context: context)) return;
                          GameManager.instance.pauseMovement();
                          var pearlCount = gameData.pearlCount;
                          //游戏结束
                          var result = await PopManager().show(
                            context: context,
                            child: GamePearlPop(
                              pearlCount: pearlCount,
                              targetIndex: 2,
                            ),
                          );
                          //2 双倍 1单倍
                          var awardResult = 1;
                          if (result == -2) {
                            await PopManager().show(
                              context: context,
                              child: NoPearlPop(),
                            );
                          } else if (result == -1) {
                            //食物
                            awardResult = await BasePopView().showScaleDialog(
                              context: context,
                              child: GameAwardPop(type: 1, money: 30),
                            );
                          } else {
                            awardResult = await BasePopView().showScaleDialog(
                              context: context,
                              child: GameAwardPop(type: 0, money: result),
                            );
                          }
                          if (result == -2) {} else if (result == -1) {
                            setState(() {
                              gameData.foodCount += 30;
                            });
                          } else {
                            await PopManager().show(
                              context: context,
                              needAlpha: 0,
                              child: CoinAnimalPop(),
                            );
                            gameData.coin += result * awardResult;
                          }
                          LocalCacheUtils.putGameData(gameData);
                          GameManager.instance.resumeMovement();
                        },
                      ),
                    ),
                    Positioned(
                      right: 16.w,
                      bottom: 5.h,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        pressedOpacity: 0.7,
                        child: Image.asset(
                          "assets/images/ic_coin2.webp",
                          width: 67.w,
                          height: 67.h,
                          fit: BoxFit.cover,
                        ),
                        onPressed: () async {
                          if (!ClickManager.canClick(context: context)) return;
                          await toCashMain(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //漂流瓶
            Positioned(
              top: 295.h,
              right: 22.w,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                pressedOpacity: 0.7,
                child: SizedBox(
                  key: globalGuideNew5,
                  width: 70.w,
                  height: 70.h,
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/images/ic_props.webp",
                        fit: BoxFit.fill,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(bottom: 2.h),
                          child: RepaintBoundary(
                            child: ValueListenableBuilder<double>(
                              valueListenable: propsNotifier,
                              builder: (_, value, __) {
                                return PropsProgress(
                                  progress: value, // 进度 0~1
                                  progressColor: GameConfig.color3,
                                ); // 只重建这一小块
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () async {
                  var progress = GameManager.instance.getPropsProgress(
                    propsTime,
                  );
                  if (!ClickManager.canClick(context: context)) return;
                  if (progress == 1 || userData.new5) {
                    var result = await PopManager().show(
                      context: context,
                      child: PropsAwardPop(),
                    );
                    if (result != null) {
                      gameData.coin += result;
                      GameManager.instance.updateCoinToGame(gameData.coin);
                      LocalCacheUtils.putGameData(gameData);
                      setState(() {
                        propsTime = 0;
                      });
                    }
                  }
                },
              ),
            ),
            buildDanger(),
            //防护
            Positioned(
              top: 220.h,
              right: 22.w,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                pressedOpacity: 0.7,
                child: SizedBox(
                  key: globalGuideNew4,
                  width: 70.w,
                  height: 70.h,
                  child: Image.asset("assets/images/ic_protect.webp"),
                ),
                onPressed: () {
                  clickProtect();
                },
              ),
            ),
            //现金气泡
            showCoinBubbles
                ? Positioned(
              left: 38.w,
              bottom: 241.h,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                pressedOpacity: 0.7,
                child: BubbleWidget(key: globalGuideNew2, type: 0),
                onPressed: () {
                  if (!ClickManager.canClick(context: context)) return;
                  setState(() {
                    showCoinBubbles = false;
                    gameData.coin += 1;
                    LocalCacheUtils.putGameData(gameData);
                    TaskManager.instance.addTask("bubbles");
                  });
                },
              ),
            )
                : SizedBox.shrink(),
            showFoodBubbles
                ? Positioned(
              left: 18.w,
              top: 300.h,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                pressedOpacity: 0.7,
                child: BubbleWidget(type: 1),
                onPressed: () {
                  if (!ClickManager.canClick(context: context)) return;
                  setState(() {
                    showFoodBubbles = false;
                    gameData.foodCount += 10;
                    LocalCacheUtils.putGameData(gameData);
                    TaskManager.instance.addTask("bubbles");
                  });
                },
              ),
            )
                : SizedBox.shrink(),
            showPearlBubbles1
                ? Positioned(
              right: 26.w,
              bottom: 300.h,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                pressedOpacity: 0.7,
                child: BubbleWidget(type: 2),
                onPressed: () {
                  if (!ClickManager.canClick(context: context)) return;
                  setState(() {
                    showPearlBubbles1 = false;
                    gameData.pearlCount += 1;
                    LocalCacheUtils.putGameData(gameData);
                    TaskManager.instance.addTask("bubbles");
                  });
                },
              ),
            )
                : SizedBox.shrink(),
            showPearlBubbles2
                ? Positioned(
              right: 26.w,
              bottom: 160.h,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                pressedOpacity: 0.7,
                child: BubbleWidget(type: 2),
                onPressed: () {
                  if (!ClickManager.canClick(context: context)) return;
                  setState(() {
                    showPearlBubbles2 = false;
                    gameData.pearlCount += 1;
                    LocalCacheUtils.putGameData(gameData);
                    TaskManager.instance.addTask("bubbles");
                  });
                },
              ),
            )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void clickProtect() {
    if (!ClickManager.canClick(context: context)) return;
    if (userData.new4) {
      userData.new4 = false;
      LocalCacheUtils.putUserData(userData);
    }
    gameData = LocalCacheUtils.getGameData();
    gameData.protectTime += getProtectTime();
    LocalCacheUtils.putGameData(gameData);
    setState(() {
      globalShowDanger2 = false;
      // ArrowOverlay.hide();
      if (globalShowDanger1) {
        GameManager.instance.hideDanger();
      }
    });
    GameManager.instance.showProtect();
    GameManager.instance.updateProtectTime(gameData.protectTime);
    GameManager.instance.resumeMovement();
    if (userData.new5) {
      showMarkNew5();
    }
  }

  Future<void> toCashMain(BuildContext context) async {
    GameManager.instance.pauseMovement();
    GlobalTimerManager().cancelTimer();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CashMain(),
        settings: const RouteSettings(name: '/CashMain'),
      ),
    );
    registerTimer();
    GameManager.instance.resumeMovement();
  }

  Widget buildAnimal() {
    LogUtils.logD("${TAG} buildAnimal");
    return Positioned.fill(
      child: Center(child: AnimalGameHolder(level: gameData.level)),
    );
  }

  Future<void> registerTimer() async {
    gameData = LocalCacheUtils.getGameData();
    userData = LocalCacheUtils.getUserData();
    bool result = await isGameOver();
    if (result) {
      return;
    }
    GlobalTimerManager().startTimer(
      onTick: () async {
        if (!allowTime) return;
        gameData = LocalCacheUtils.getGameData();
        if (gameData.level > 0 && gameData.levelTime >= 1) {
          gameData.levelTime -= 1;
        }
        propsTime++;
        aliveTime++;
        if (gameData.level > 1) {
          cutTime++;
          GameManager.instance.addCoin(gameData);
        }
        if (cutTime == getCutTime()) {
          cutTime = 0;
          GameManager.instance.cutLife(gameData);
          if (gameData.life <= 0) {
            GlobalTimerManager().cancelTimer();
            //游戏结束
            bool result = await isGameOver();
            if (result) return;
          }
        }
        if (gameData.protectTime > 0) {
          gameData.protectTime -= 1;
        } else {
          gameData.protectTime = 0;
        }
        LocalCacheUtils.putGameData(gameData);
        if (aliveTime == GameConfig.gameDangerTime1 ||
            aliveTime == GameConfig.gameDangerTime2 ||
            aliveTime == GameConfig.gameDangerTime3) {
          showDanger();
        }
        progress = GameManager.instance.getCurrentProgress(gameData);
        SchedulerBinding.instance.addPostFrameCallback((_) {
          globalTimeListener.value = progress;
          lifeNotifier.value = gameData.life;
          propsNotifier.value = GameManager.instance.getPropsProgress(
            propsTime,
          );
          GameManager.instance.updateCoinToGame(gameData.coin);
          GameManager.instance.updateProtectTime(gameData.protectTime);
        });
      },
    );
  }

  Future<bool> isGameOver({bool force = false}) async {
    if (gameData.life <= 0 || force) {
      GlobalTimerManager().cancelTimer();
      //游戏结束
      var result = await PopManager().show(
        context: context,
        child: GameFailPop(),
      );
      if (result == 0) {
        GameManager.instance.reset(gameData);
        lifeNotifier.value = 0;
        registerTimer();
        cutTime = 0;
        aliveTime = 0;
        setState(() {
          LocalCacheUtils.putGameData(gameData);
        });
        return true;
      }
    }
    return false;
  }

  buildFood() {
    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      child: globalShowFood
          ? DropFadeImage(
        key: GlobalKey(),
        child: Image.asset(
          "assets/images/ic_food.webp",
          width: 46.w,
          height: 46.h,
        ),
      )
          : SizedBox.shrink(),
    );
  }

  buildShark() {
    return globalShowShark
        ? SharkWidget(
      key: GlobalKey(),
      imagePath: "assets/images/ic_shark.webp",
      top: 420.h,
      width: 204.w,
      height: 101.h,
    )
        : SizedBox.shrink();
  }

  buildDanger() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (globalShowDanger2) {
        // ArrowOverlay.hide();
        // ArrowOverlay.show(context, ArrowWidget());
        firstShowProtectKey = false;
        LocalCacheUtils.putBool(LocalCacheConfig.firstShowProtectKey, false);
      }
    });

    return Positioned.fill(
      child: globalShowDanger2
          ? Stack(
        children: [
          Positioned(
            bottom: 110.h,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity, // 宽度，可根据需求修改
              height: 71.h, // 高度，可根据需求修改
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xBFE5452D), // 上方不透明红色
                    Color(0x00E5452D), // 下方透明
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 200.h,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity, // 宽度，可根据需求修改
              height: 71.h, // 高度，可根据需求修改
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xBFE5452D), // 上方不透明红色
                    Color(0x00E5452D), // 下方透明
                  ],
                ),
              ),
            ),
          ),
          firstShowProtectKey
              ? Stack(
            children: [
              // 全屏黑色遮盖
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(
                    0.6,
                  ), // 黑色 + 0.8透明度
                ),
              ),
              Positioned(
                left: 23.w,
                top: 130.h,
                child: Image.asset(
                  "assets/images/ic_fish_tips.webp",
                  width: 75.w,
                  height: 75.h,
                ),
              ),
              Positioned(
                top: 123.h,
                left: 86.w,
                right: 21.w,
                child: SizedBox(
                  width: double.infinity,
                  height: 74.h,
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/images/bg_level_up.webp",
                        width: double.infinity,
                        height: 74.h,
                        fit: BoxFit.fill,
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsetsGeometry.fromLTRB(
                            32.w,
                            0.h,
                            20.w,
                            0.h,
                          ),
                          child: AutoSizeText(
                            "app_danger_tips".tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF651922),
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
              : SizedBox.shrink(),
        ],
      )
          : SizedBox.shrink(),
    );
  }

  var isShowDanger = false;

  void showDanger() {
    if (isShowDanger) return;
    isShowDanger = true;
    if (globalShowDanger2) return;
    setState(() {
      globalShowDanger2 = true;
      // GameManager.instance.swimToCenter();
    });
    if (!globalShowProtect) {
      GameManager.instance.pauseMovement();
      GameManager.instance.showDanger();
    }
    var timeCount = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      timeCount++;
      AudioUtils().playTempAudio("audio/danger.mp3");
      if (timeCount == 5) {
        _timer?.cancel();
        setState(() {
          globalShowDanger2 = false;
          // ArrowOverlay.hide();
          GameManager.instance.hideDanger();
        });
        Future.delayed(const Duration(milliseconds: 1000), () async {
          if (!mounted) return;
          setState(() {
            globalShowShark = true;
            GameManager.instance.resumeMovement();
          });
        });
        Future.delayed(const Duration(milliseconds: 2000), () async {
          if (!mounted) return;
          isShowDanger = false;
          globalShowShark = false;
          if (!globalShowProtect) {
            bool result = await isGameOver(force: true);
            if (result) {
              return;
            }
          } else {
            TaskManager.instance.addTask("defend");
          }
        });
      }
    });
  }

  /// 监听 App 生命周期切换
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      LogUtils.logD("${TAG} resumed");
      GameManager.instance.resumeMovement();
      registerTimer();
    } else if (state == AppLifecycleState.paused) {
      LogUtils.logD("${TAG} paused");
      GameManager.instance.pauseMovement();
      GlobalTimerManager().cancelTimer();
    }
  }

  TutorialCoachMark? tutorialCoachMark;
  late List<TargetFocus> globalGuideNew1Keys;
  GlobalKey globalGuideNew1 = GlobalKey();
  GlobalKey globalGuideNew2 = GlobalKey();
  GlobalKey globalGuideNew4 = GlobalKey();
  GlobalKey globalGuideNew5 = GlobalKey();

  /**
   * 0°	0	不旋转
      45°	math.pi / 4	右上方向
      90°	math.pi / 2	向上
      180°	math.pi	倒置
      270°	3 * math.pi / 2
   */
  void showMarkNew1() {
    globalGuideNew1Keys = [];
    globalGuideNew1Keys.add(
      TargetFocus(
        identify: "guideNew1",
        keyTarget: globalGuideNew1,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        radius: 0.3,
        // 🔹 原来是 0.5，现在更小
        paddingFocus: 0,
        // 🔹 缩紧圆圈贴近目标
        // 圆角半径，自行调整
        contents: [
          TargetContent(
            align: ContentAlign.top, // 内容在高亮 widget 下方
            child: Stack(
              children: [
                Transform.translate(
                  offset: const Offset(30, 30), // 🔹 上移 20 像素，让内容更贴近高亮圈
                  child: Transform.rotate(
                    angle: math.pi,
                    child: Image.asset(
                      "assets/images/ic_arrow.webp",
                      width: 100.w,
                      height: 100.h,
                    ),
                  ),
                )
              ],
            ),
          ),

        ],
      ),
    );
    tutorialCoachMark = TutorialCoachMark(
      targets: globalGuideNew1Keys,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: "",
      paddingFocus: 0,
      onFinish: () {
        // eventBus.fire(NotifyEvent("new2"));
        showMarkNew2();
      },
      onClickTarget: (target) {
        clickFood();
      },
    );
    tutorialCoachMark?.show(context: context);
  }

  void showMarkNew2() {
    userData.new1 = false;
    LocalCacheUtils.putUserData(userData);
    // 创建控制器
    globalGuideNew1Keys = [];
    globalGuideNew1Keys.add(
      TargetFocus(
        identify: "guideNew2",
        keyTarget: globalGuideNew2,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        radius: 1.0,
        // 圆角半径，自行调整
        contents: [
          TargetContent(
            align: ContentAlign.bottom, // 内容在高亮 widget 下方
            child: Stack(
              children: [
                Transform.translate(
                  offset: const Offset(100, 0), // 🔹 上移 20 像素，让内容更贴近高亮圈
                  child: Image.asset(
                    "assets/images/ic_arrow.webp",
                    width: 100.w,
                    height: 100.h,
                  ),
                )
              ],
            ),
          ),

        ],
      ),
    );
    tutorialCoachMark = TutorialCoachMark(
      targets: globalGuideNew1Keys,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: "",
      paddingFocus: 0,
      onFinish: () {},
      onClickTarget: (target) {
        if (!ClickManager.canClick(context: context)) return;
        GameManager.instance.pauseMovement();
        setState(() {
          showCoinBubbles = false;
        });
        Future.delayed(Duration(milliseconds: 500), () async {
          await PopManager().show(
            context: context,
            needAlpha: 0,
            child: CoinAnimalPop(),
          );
          gameData.coin += 1;
          LocalCacheUtils.putGameData(gameData);
          GameManager.instance.updateCoinToGame(gameData.coin);
          GameManager.instance.resumeMovement();
          eventBus.fire(NotifyEvent(EventConfig.new3));
        });
      },
    );
    tutorialCoachMark?.show(context: context);
  }

  void showMarkNew4() {
    // 创建控制器
    globalGuideNew1Keys = [];
    globalGuideNew1Keys.add(
      TargetFocus(
        identify: "guideNew4",
        keyTarget: globalGuideNew4,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        radius: 1.0,
        // 圆角半径，自行调整
        contents: [
          TargetContent(
            align: ContentAlign.bottom, // 内容在高亮 widget 下方
            child: Stack(
              children: [
                Transform.translate(
                  offset: Offset(180.w, 0), // 🔹 上移 20 像素，让内容更贴近高亮圈
                  child: Transform.rotate(
                    angle: math.pi / 4,
                    child: Image.asset(
                      "assets/images/ic_arrow.webp",
                      width: 100.w,
                      height: 100.h,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
    tutorialCoachMark = TutorialCoachMark(
      targets: globalGuideNew1Keys,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: "",
      paddingFocus: 0,
      onFinish: () {
        clickProtect();
      },
      onClickTarget: (target) {

      },
    );
    tutorialCoachMark?.show(context: context);
  }

  void showMarkNew5() {
    GameManager.instance.pauseMovement();
    // 创建控制器
    globalGuideNew1Keys = [];
    globalGuideNew1Keys.add(
      TargetFocus(
        identify: "guideNew5",
        keyTarget: globalGuideNew5,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        radius: 1.0,
        // 圆角半径，自行调整
        contents: [
          TargetContent(
            align: ContentAlign.bottom, // 内容在高亮 widget 下方
            child: Stack(
              children: [
                Transform.translate(
                  offset: Offset(180.w, 0), // 🔹 上移 20 像素，让内容更贴近高亮圈
                  child: Transform.rotate(
                    angle: math.pi / 4,
                    child: Image.asset(
                      "assets/images/ic_arrow.webp",
                      width: 100.w,
                      height: 100.h,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
    tutorialCoachMark = TutorialCoachMark(
      targets: globalGuideNew1Keys,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: "",
      paddingFocus: 0,
      onFinish: () async {
        if (!ClickManager.canClick(context: context)) return;
        tutorialCoachMark?.skip();
        var result = await PopManager().show(
          context: context,
          child: PropsAwardPop(),
        );
        if (result != null) {
          gameData.coin += result;
          GameManager.instance.updateCoinToGame(gameData.coin);
          LocalCacheUtils.putGameData(gameData);
        }
        GameManager.instance.resumeMovement();
        userData.new5 = false;
        LocalCacheUtils.putUserData(userData);
        await toCashMain(context);
      },
      onClickTarget: (target) {

      },
    );
    tutorialCoachMark?.show(context: context);
  }

  void clickFood() {
    if (!ClickManager.canClick(context: context)) return;
    if (gameData.foodCount < 10) {
      GameManager.instance.showTips("app_not_enough_food".tr());
      return;
    } else {
      var foodCount = LocalCacheUtils.getInt(
        LocalCacheConfig.cacheKeyFoodCount,
      );
      foodCount += 1;
      var showBubble = false;
      if (foodCount % 2 == 0) {
        showBubble = true;
      }
      LocalCacheUtils.putInt(LocalCacheConfig.cacheKeyFoodCount, foodCount);
      setState(() {
        if (showBubble) {
          showPearlBubbles2 = true;
        }
        if (globalShowFood) return;
        globalShowFood = true;
        gameData.foodCount -= 10;
        GameManager.instance.addLife(gameData);
        LocalCacheUtils.putGameData(gameData);
      });
      Future.delayed(Duration(seconds: 1), () {
        globalShowFood = false;
      });
      TaskManager.instance.addTask("feed");
    }
  }
}
