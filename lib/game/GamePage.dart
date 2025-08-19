import 'package:fish_earn/utils/GlobalTimerManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameProcess.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../data/GameData.dart';
import '../model/GameViewModel.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameData gameData;
  late double progress;

  @override
  void initState() {
    super.initState();
    GlobalTimerManager().startTimer(
      onTick: () {
        setState(() {
          gameData.levelTime -= 1;
          LocalCacheUtils.putGameData(gameData);
        });
      },
    );
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
              child: GameProgress(gameData:gameData,progress:progress ),
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
        ],
      ),
    );
  }
}
