import 'dart:ffi';

import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/task/TaskManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';

import 'LogUtils.dart';

class TimeUtils{

  static var TAG = "TimeUtils";

  static void dataReset(){
    var day = LocalCacheUtils.getInt(LocalCacheConfig.cacheDataRestKey);
    var laseDay = getFormattedDate(day);
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    var currentDay = getFormattedDate(timestamp);
    if(laseDay!=currentDay){
      LogUtils.logD("dataReset->currentDay:${currentDay}");
      LocalCacheUtils.putInt(LocalCacheConfig.cacheDataRestKey, timestamp);
      if(isConsecutiveDay(day,timestamp)){
        TaskManager.instance.addLogin(day,timestamp);
      }
      // CacheManager.putBool(CacheConfig.cacheDayCashKey, true);
      // var user = CacheManager.getUser();
      // if(user.userRisk && user.riskType == 1){
      //   user.riskType = 0;
      //   user.userRisk = false;
      //   CacheManager.putUser(user);
      // }
    }
  }

  static String getFormattedDate(int timestamp) {
    final formatter = DateFormat('yyyyMMdd', 'en_US'); // 强制使用默认内置的 en_US
    return formatter.format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  static bool isConsecutiveDay(int lastDay, int currentDay) {
    // 转换为 DateTime（假设时间戳是毫秒）
    final last = DateTime.fromMillisecondsSinceEpoch(lastDay);
    final current = DateTime.fromMillisecondsSinceEpoch(currentDay);

    // 去除时分秒，只保留日期
    final lastDate = DateTime(last.year, last.month, last.day);
    final currentDate = DateTime(current.year, current.month, current.day);

    // 计算相差天数
    final diff = currentDate.difference(lastDate).inDays;
    LogUtils.logD("${TAG} diff:$diff");
    return diff == 1;
  }
}