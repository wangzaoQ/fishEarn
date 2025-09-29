class GameConfig {
  static const time_1_2 = 1 * 30;
  static const time_2_3 = 2 * 30;
  static const time_ad = 2 * 30;
  static const color1 = 0xFF239611;
  static const color2 = 0xFFC7BD48;
  static const color3 = 0xFF5BC025;

  //TODO线上需改
  //生命值每 cutTime 秒进行一次减少。生命值默认100
  static const cutTime = 60;
  //每次喂食增加生命值
  static const gameAddLife = 10;
  //每次生命值减少的值 测试一次减少10% 正式2%
  static const gameCutLife = 10;
  //防护时间 正式 120
  static const protectTime = 10;
  // 复活需要金币数 正式 10
  static const gameLifeCoin = 10;

  //漂流瓶 进度时间 正式 5*60
  static const gamePropsTime = 10;
  // 第一个危险出现时间 正式 3*60
  static const gameDangerTime1 = 1*60;
  // 第二个危险出现时间 正式 8*60
  static const gameDangerTime2 = 2*60;
  // 第三个危险出现时间 正式 11*60
  static const gameDangerTime3 = 3*60;
}