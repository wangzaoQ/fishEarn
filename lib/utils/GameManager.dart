
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../config/GameConfig.dart';
import '../config/global.dart';
import '../data/GameData.dart';
import '../game/FishAnimGame.dart';

class GameManager{
  // 私有构造函数
  GameManager._();
  SimpleAnimGame? game;

  // 全局唯一实例
  static final GameManager instance = GameManager._();

  double getCurrentProgress(GameData gameData) {
    var all = GameConfig.time_1_2+GameConfig.time_2_3;
    if(gameData.level == 1){
      var all = GameConfig.time_1_2;
      var progress = ((all-gameData.levelTime)/all);
      progress = progress>=1?1:progress;
      return 0.5 *progress;
    }else if(gameData.level == 2){
      if(gameData.levelTime<=0){
        gameData.levelTime = 0;
      }
      var all = GameConfig.time_2_3;
      var progress = ((all-gameData.levelTime)/all);
      progress = progress>=1?1:progress;
      progress = (0.5 *progress)+0.5;
      return progress;
    }
    return 1;
  }

  void showProtect() {
    game?.showProtect();
  }

  void showDanger() {
    game?.showDanger();
  }

  void hideDanger() {
    game?.hideDanger();
  }

  void hideProtect() {
    game?.hideProtect();
  }

  void pauseMovement(){
    game?.pauseMovement();
  }

  void resumeMovement(){
    game?.resumeMovement();
  }

  void swimToCenter(){
    game?.swimToCenter();
  }


  updateCoinToGame(double coin){
    game?.updateCoin(coin);
  }

  updateProtectTime(int time){
    game?.updateProtectTime(time);
  }

  addCoin(GameData gameData){
    if(gameData.level == 2){
      gameData.coin+=0.02;
    }else if(gameData.level == 3){
      gameData.coin+=0.05;
    }
  }

  cutLife(GameData gameData){
    if(gameData.level == 1)return;
    gameData.life-=GameConfig.lifeIncreaseAmount;
    if(gameData.life<0){
      gameData.life = 0;
    }
  }

  // int getLifeColor(int process){
  //   if(process >=60){
  //     return GameConfig.color1;
  //   }else if(process>=30){
  //     return GameConfig.color2;
  //   }else{
  //     return GameConfig.color3;
  //   }
  // }


  void showTips(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black.withOpacity(0.7),
      textColor: Colors.white,
      fontSize: 15.sp,
    );
  }

  void reset(GameData gameData) {
    allowTime = true;
    globalShowFood = false;
    globalShowDanger1 = false;
    globalShowDanger2 = false;
    globalShowShark = false;
    globalShowProtect = false;
    gameData.level = 1;
    gameData.levelTime = GameConfig.time_1_2;
    gameData.life = 100;
    gameData.protectTime = 0;
    LocalCacheUtils.putGameData(gameData);
  }

  void addLife(GameData gameData) {
    gameData.life+=GameConfig.lifeIncreaseAmount;
    if(gameData.life>100){
      gameData.life = 100;
    }
  }

  double getPropsProgress(int propsTime) {
    if(propsTime>GameConfig.bottleDuration){
      return 1.0;
    }else{
      return propsTime/GameConfig.bottleDuration;
    }
  }

}