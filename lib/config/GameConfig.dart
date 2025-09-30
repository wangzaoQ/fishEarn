import 'package:flutter/material.dart';

class GameConfig {

  static const time_ad = 2 * 30;
  static const color1 = Colors.red;
  static const color2 = Colors.yellow;
  static const color3 = Colors.green;

  //TODO线上需改
  //进度1升2(正式 3 * 60)
  static const time_1_2 = 3 * 60;
  //进度1升2(正式 10 * 60)
  static const time_2_3 = 2 * 30;
  // ====== 生命值相关 ======
  //生命值每 lifeDecreaseInterval 秒进行一次减少。生命值默认100 (正式60s)
  static const lifeDecreaseInterval = 60;
  //每次喂食增加生命值 (正式10)
  static const lifeIncreaseAmount = 10;
  //每次减少的生命值 (测试10% / 正式2%)
  static const lifeDecreaseAmount = 2;

  // ====== 防护/复活 ======
  // 防护时间 (正式120s)
  static const protectDuration = 120;
  // 复活需要金币数 正式 10
  static const reviveCostCoin = 10;

  // ====== 道具/危险事件 ======
  // 漂流瓶进度时间 (正式 5*60)
  static const bottleDuration = 5*60;
  // ====== 道具/危险事件 ======
  // 第一个危险出现时间 (正式 3*60)
  static const gameDangerTime1 = 3 * 60;
  // 第二个危险出现时间 (正式 8*60)
  static const gameDangerTime2 = 8 * 60;
  // 第三个危险出现时间 (正式 11*60)
  static const gameDangerTime3 = 11 * 60;

}
