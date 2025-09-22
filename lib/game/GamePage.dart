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

import '../data/GameData.dart';
import '../model/GameViewModel.dart';
import '../view/GameLifeProgress.dart';
import '../view/GameText.dart';
import '../view/pop/LevelPop2_3.dart';
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

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    // GlobalTimerManager().startTimer(
    //   onTick: () {
    //     setState(() {
    //       if (gameData.level > 0) {
    //         gameData.levelTime -= 1;
    //         LocalCacheUtils.putGameData(gameData);
    //       }
    //     });
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    gameData = LocalCacheUtils.getGameData();
    progress = gameData.getCurrentProgress();
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
              child: GameProgress(
                gameData: gameData,
                progress: progress,
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
          Positioned(
            top: 310.h,
            left: 32.w,
            child: GameLifePage(),
          ),
          // Positioned(child:SizedBox(child: CustomProgress3(progress: 0.5),) )
        ],
      ),
    );
  }

  Widget buildAnimal() {
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
      return Padding(padding: EdgeInsetsGeometry.only(left: 0,top: 100.h,right: 0,bottom: 110.h),child: Container(
        color: Colors.transparent, // 外层透明
        child: GameWidget(
          game: SimpleAnimGame(),
        ),
      ),);GameWidget(
        game: SimpleAnimGame(), // 直接把游戏传进去
      );
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
