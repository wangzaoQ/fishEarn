import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/GameConfig.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/GlobalTimerManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/DropFadeImage.dart';
import 'package:fish_earn/view/GameProcess.dart';
import 'package:fish_earn/view/SharkWidget.dart';
import 'package:fish_earn/view/pop/GameFailPop.dart';
import 'package:fish_earn/view/pop/LevelPop1_2.dart';
import 'package:fish_earn/view/pop/PopManger.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../config/global.dart';
import '../data/GameData.dart';
import '../model/GameViewModel.dart';
import '../utils/LogUtils.dart';
import '../view/GameLifeProgress.dart';
import '../view/GameText.dart';
import '../view/PropsProgress.dart';
import '../view/pop/LevelPop2_3.dart';
import 'AnimalGameHolder.dart';
import 'FishAnimGame.dart';
import 'GameLifePage.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late GameData gameData;
  late double progress;
  AnimationController? _lottieController;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  var TAG = "GamePage";

  //生命相关
  var cutTime = 0;
  //道具相关
  var propsTime = 0;
  var aliveTime = 0;

  int getCutTime() {
    return GameConfig.cutTime;
  }

  int getProtectTime() {
    return GameConfig.protectTime;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    registerTimer();
  }

  @override
  Widget build(BuildContext context) {
    gameData = LocalCacheUtils.getGameData();
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/bg_game.webp", fit: BoxFit.cover),
          ),
          // top bar
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
                      onPressed: () {},
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
                        setState(() {
                          if (result == 2) {
                            //level 2升级
                            _lottieController?.dispose();
                          } else if (result == 3) {
                            PopManager().show(
                              context: context,
                              child: LevelPop2_3(),
                            );
                          }
                        });
                      },
                    ); // 只重建这一小块
                  },
                ),
              ),
            ),
          ),
          //鱼生命进度
          gameData.level == 1
              ? SizedBox.shrink()
              : Positioned(top: 310.h, left: 32.w, child: GameLifePage()),
          //鱼动画
          buildAnimal(),
          buildFood(),
          buildDanger(),
          buildShark(),
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
                          "assets/images/ic_play.webp",
                          height: 109.h,
                          width: 197.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      onPressed: () {
                        if (gameData.foodCount <= 0) {
                          GameManager.instance.showTips("app_not_enough_food".tr());
                          return;
                        } else {
                          setState(() {
                            if (globalShowFood) return;
                            globalShowFood = true;
                            gameData.foodCount -= 1;
                            GameManager.instance.addLife(gameData);
                            LocalCacheUtils.putGameData(gameData);
                          });
                          Future.delayed(Duration(seconds: 1), () {
                            globalShowFood = false;
                          });
                        }
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
                ],
              ),
            ),
          ),
          Positioned(
            top: 220.h,
            right: 22.w,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              pressedOpacity: 0.7,
              child: SizedBox(
                width: 70.w,
                height: 70.h,
                child: Image.asset("assets/images/ic_protect.webp"),
              ),
              onPressed: () {
                gameData = LocalCacheUtils.getGameData();
                gameData.protectTime += getProtectTime();
                LocalCacheUtils.putGameData(gameData);
                GameManager.instance.showProtect();
              },
            ),
          ),
          Positioned(
            top: 295.h,
            right: 22.w,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              pressedOpacity: 0.7,
              child: SizedBox(
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
                                progressColor: Color(GameConfig.color3),
                              ); // 只重建这一小块
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onPressed: () {
              },
            ),
          ),
          // Align(
          //   alignment: Alignment.topCenter,
          //   child: Padding(
          //     padding: EdgeInsetsGeometry.only(top: 529.h),
          //     child: SizedBox(width: 124.w, height: 47.h, child: Stack(children: [
          //       Image.asset("assets/images/bg_protect.webp",fit: BoxFit.fill,),
          //       Positioned(
          //           right: 12.w,
          //           top: 13.h,
          //           child: Text(GlobalTimerManager().formatTime(getProtectTime()),style: TextStyle(color: Color(0xFF561C3E),fontSize: 15.sp,fontWeight: FontWeight.bold),))
          //     ],)),
          //   ),
          // ),
          gameData.level == 1
              ? SizedBox.shrink()
              : Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsetsGeometry.only(top: 268.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // ← 子元素水平居中
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/ic_coin.webp",
                          width: 50.w,
                          height: 50.h,
                        ),
                        GameText(
                          showText:
                              "+\$${gameData.level == 2 ? "0.001" : "0.005"}/1s",
                          fontSize: 28.sp,
                          fillColor: Color(0xFFFFEF50),
                          strokeColor: Color(0xFF9B4801),
                          strokeWidth: 2.w,
                        ),
                      ],
                    ),
                  ),
                ),
          // Positioned(child:SizedBox(child: CustomProgress3(progress: 0.5),) )
        ],
      ),
    );
  }

  Widget buildAnimal() {
    LogUtils.logD("${TAG} buildAnimal");
    return Positioned.fill(
      child: Center(child: AnimalGameHolder(level: gameData.level)),
    );
    if (gameData.level == 1) {
      return Positioned.fill(
        child: Center(
          child: SizedBox(
            width: 100.w,
            height: 100.h,
            child: Lottie.asset(
              'assets/animations1/data.json',
              width: 96.w,
              height: 52.h,
              controller: _lottieController,
            ),
          ),
        ),
      );
    } else if (gameData.level == 2) {
      return Positioned.fill(child: Center(child: AnimalGameHolder(level: 2)));
    } else {
      return Positioned.fill(
        child: Center(
          child: SizedBox(
            width: 160.w,
            height: 160.h,
            child: Image.asset(
              "assets/images/ic_game2_large.webp",
              height: 160.h,
              width: 160.w,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    animalDispose();
    super.dispose();
  }

  void animalDispose() {
    // ✅ 释放 Lottie 占用的资源
    _lottieController?.dispose();
  }

  Future<void> registerTimer() async {
    _lottieController = AnimationController(vsync: this);
    gameData = LocalCacheUtils.getGameData();
    bool result = await isGameOver();
    if (result) {
      return;
    }
    GlobalTimerManager().startTimer(
      onTick: () async {
        if (!allowTime) return;
        var cutProtectTime = false;
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
          cutProtectTime = true;
          gameData.protectTime -= 1;
        } else {
          gameData.protectTime = 0;
          cutProtectTime = false;
        }
        LocalCacheUtils.putGameData(gameData);
        if(aliveTime == GameConfig.gameDangerTime1 || aliveTime == GameConfig.gameDangerTime2 || aliveTime == GameConfig.gameDangerTime3){
          showDanger();
        }
        progress = GameManager.instance.getCurrentProgress(gameData);
        SchedulerBinding.instance.addPostFrameCallback((_) {
          globalTimeListener.value = progress;
          lifeNotifier.value = gameData.life;
          propsNotifier.value = GameManager.instance.getPropsProgress(propsTime);
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
        registerTimer();
        cutTime = 0;
        setState(() {});
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

  buildShark(){
    return Positioned(
      top: 0,
      right: 0,
      child:globalShowShark? SharkWidget(
        key: GlobalKey(),
        imagePath: "assets/images/ic_shark.webp",
        top: 420.h,
        width: 204.w,
        height: 101.h,
      ):SizedBox.shrink(),
    );
  }

  buildDanger() {
    return Positioned.fill(
      child: globalShowDanger
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
              ],
            )
          : SizedBox.shrink(),
    );
  }

  var isShowDanger = false;
  void showDanger() {
    if(isShowDanger)return;
    isShowDanger = true;
    setState(() {
      if (globalShowDanger) return;
      globalShowDanger = true;
      // GameManager.instance.swimToCenter();
      GameManager.instance.pauseMovement();
      GameManager.instance.showDanger();
    });
    Future.delayed(Duration(seconds: 5), () {
      if(!mounted)return;
      setState(() {
        globalShowDanger = false;
        globalShowShark = true;

        GameManager.instance.hideDanger();
        GameManager.instance.resumeMovement();
      });
      Future.delayed(const Duration(milliseconds: 2000), () async {
        if(!mounted)return;
        isShowDanger = false;
        if(!globalShowProtect){
          bool result = await isGameOver(force: true);
          if (result) {
            return;
          }
        }
      });
    });
  }
}
