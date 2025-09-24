import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/utils/GlobalTimerManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameProcess.dart';
import 'package:fish_earn/view/pop/LevelPop1_2.dart';
import 'package:fish_earn/view/pop/PopManger.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../config/global.dart';
import '../data/GameData.dart';
import '../model/GameViewModel.dart';
import '../utils/LogUtils.dart';
import '../view/GameLifeProgress.dart';
import '../view/GameText.dart';
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

  var TAG = "GamePage";

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    gameData = LocalCacheUtils.getGameData();
    GlobalTimerManager().startTimer(
      onTick: () async{
        if(!allowTime)return;
        gameData = LocalCacheUtils.getGameData();
        if (gameData.level > 0) {
          gameData.levelTime -= 1;
          LocalCacheUtils.putGameData(gameData);
        }
        progress = gameData.getCurrentProgress();
        globalTimeListener.value = progress;
      },
    );
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
                    top: 11.h,
                    left: 18.w,
                    child: Stack(
                      children: [
                        Image.asset(
                          "assets/images/bg_to_bar_coin.webp",
                          width: 90.w,
                          height: 25.h,
                          fit: BoxFit.cover,
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              "${gameData.coin}",
                              style: TextStyle(
                                color: Color(0xFFF4FF72),
                                fontSize: 15.sp,
                                fontFamily: "AHV",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    "assets/images/ic_coin.webp",
                    width: 45.w,
                    height: 45.h,
                    fit: BoxFit.cover,
                  ),
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
              child: RepaintBoundary(child: ValueListenableBuilder<double>(
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
                          PopManager().show(context: context, child: LevelPop2_3());
                        }
                      });
                    },
                  ); // 只重建这一小块
                },
              ))
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
                      height: 76.h,
                      fit: BoxFit.cover,
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
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          //鱼动画
          buildAnimal(),
          //鱼生命进度
          Positioned(top: 310.h, left: 32.w, child: GameLifePage()),
          gameData.level == 1?SizedBox.shrink():
          Align(
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
                    showText: "+\$${gameData.level == 2?"0.001":"0.005"}/1s",
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
      return Positioned.fill(
        child: Center(
          child: AnimalGameHolder(level: 2),
        ),
      );
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
}
