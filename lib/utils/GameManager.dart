import 'dart:ffi';

import 'package:flame/components.dart';

import '../config/GameConfig.dart';
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
        gameData.levelTime = GameConfig.time_2_3;
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

  updateCoinToGame(double coin){
    game?.updateCoin(coin);
  }

  addCoin(GameData gameData){
    if(gameData.level == 2){
      gameData.coin+=0.001;
    }else if(gameData.level == 3){
      gameData.coin+=0.005;
    }
  }

  cutLife(GameData gameData){
    gameData.life-=10;
    if(gameData.life<0){
      gameData.life = 0;
    }
  }

  int getLifeColor(int process){
    if(process >=60){
      return GameConfig.color1;
    }else if(process>=30){
      return GameConfig.color2;
    }else{
      return GameConfig.color3;
    }
  }

}