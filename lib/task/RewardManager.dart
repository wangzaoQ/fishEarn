import 'dart:math';

import 'package:faker/faker.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/utils/LogUtils.dart';
import 'package:fish_earn/utils/TimeUtils.dart';

import '../config/CashConfig.dart';
import '../data/QueueUser.dart';
import '../data/RewardData.dart';

class RewardManager {
  RewardManager._();

  // 全局唯一实例
  static final RewardManager instance = RewardManager._();

  var TAG = "RewardManager";

  var random = Random();

  RewardData? rewardData;


  /// 所有提现配置

  void init(Map<String, dynamic>? initialTasks) async{
    try{
      if (initialTasks != null) {
        rewardData = RewardData.fromJson(initialTasks);
      }
    }catch (e){
      LogUtils.logE("$TAG init error $e");
    }
    if(rewardData == null){
      rewardData = RewardData.fromJson(CashConfig.defaultReward);
    }
  }

  double findReward(List<RewardRange>? rewardList, double value) {
    if(rewardList == null)return 0.0;
    if (rewardList.isEmpty) {
      return 0.0;
    }

    // 默认使用最后一个范围
    var currentItem = rewardList.last;

    // 查找匹配区间
    for (var item in rewardList) {
      if (value >= item.firstNumber && value < item.endNumber) {
        currentItem = item;
        break;
      }
    }

    double randomValue;

    // 情况 1：两个值表示范围 [min, max]
    if (currentItem.prize.length == 2) {
      double min = currentItem.prize[0].toDouble();
      double max = currentItem.prize[1].toDouble();

      // 生成 (min, max) 的随机 double，保留两位小数
      randomValue = min + random.nextDouble() * (max - min);
      randomValue = double.parse(randomValue.toStringAsFixed(2));
    }
    // 情况 2：单值
    else {
      var min = currentItem.prize[0];
      var max = min+1;
      randomValue = min + random.nextDouble() * (max - min);
      randomValue = double.parse(randomValue.toStringAsFixed(2));
    }

    LogUtils.logD("findReward: $randomValue");
    return randomValue;
  }

}
