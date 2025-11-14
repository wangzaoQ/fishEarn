import 'dart:async';

import 'package:fish_earn/utils/GlobalDataManager.dart';

import '../config/LocalCacheConfig.dart';
import '../config/global.dart';
import 'GameManager.dart';
import 'LocalCacheUtils.dart';

class GlobalTimerManager{
  static final GlobalTimerManager _instance = GlobalTimerManager._internal();
  factory GlobalTimerManager() => _instance;
  GlobalTimerManager._internal();

  Timer? _timer;
  Timer? _timer2;

  /// 开启定时器
  void startTimer({
    required void Function() onTick,
  }) {
    cancelTimer(); // 先取消之前的
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      onTick();
    });
  }

  var unLimitedTime = 0;

  /// 开启定时器 无限转盘
  void startTimer2() {
    cancelTimer(); // 先取消之前的
    unLimitedTime = GlobalDataManager.instance.getUnLimitedTime();
    _timer2 = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(adIsPlay)return;
      GameManager.instance.updateUnLimitTime(unLimitedTime);
      unLimitedTime-=1;
      if(unLimitedTime <= 0){
        cancelTimer2();
      }
    });
  }

  bool isTimer2Running(){
    return unLimitedTime>0;
  }

  /// 取消定时器
  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// 取消定时器
  void cancelTimer2() {
    LocalCacheUtils.putBool(LocalCacheConfig.firstShowCashTips, true);
    GameManager.instance.updateUnLimitTime(0);

    _timer2?.cancel();
    _timer2 = null;
  }

  /// 是否运行中
  bool get isRunning => _timer?.isActive ?? false;


  String formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

}