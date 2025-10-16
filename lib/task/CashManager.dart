import 'dart:math';

import 'package:faker/faker.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/utils/LogUtils.dart';
import 'package:fish_earn/utils/TimeUtils.dart';

import '../config/CashConfig.dart';
import '../data/QueueUser.dart';

class CashManager {
  CashManager._();

  // 全局唯一实例
  static final CashManager instance = CashManager._();

  var TAG = "CashManager";

  var random = Random();


  /// 所有提现配置
  Map<String, dynamic> ranks = {};

  void init(Map<String, dynamic>? initialTasks) async{
    if (initialTasks != null) {
      ranks = Map<String, dynamic>.from(initialTasks);
    }else{
      ranks = Map<String, dynamic>.from(CashConfig.defaultRank);
    }
  }

  String maskPhone(String phone) {
    if (phone.length < 4) return phone;
    return '${phone[0]}****${phone.substring(phone.length - 3)}';
  }

  String maskEmail(String email) {
    final parts = email.split('@');
    if (parts[0].length <= 2) return email;
    return '${parts[0].substring(0, 2)}****@${parts[1]}';
  }
  //生成显示的排行队列
  List<QueueUser> generateQueue() {
    List<dynamic> queueList = ranks["queue"];
    LogUtils.logD("$TAG generateQueue ranks:${ranks}");
    if (queueList.isEmpty)return[];
    Map<String, dynamic> firstQueue = queueList[0];

    // 获取 m_m 和 s_s
    List<dynamic> mM = firstQueue["m_m"];
    List<dynamic> sS = firstQueue["s_s"];

    // 转成 int 类型列表
    List<int> mMInts = mM.map((e) => e as int).toList();
    List<int> sSInts = sS.map((e) => e as int).toList();
    LogUtils.logD("$TAG range rm_m: $mMInts s_s: $sSInts");

    // 如果你想取随机值
    int randomM = mMInts[random.nextInt(mMInts.length)];
    int randomS = sSInts[random.nextInt(sSInts.length)];
    LogUtils.logD("$TAG random value m_m: $randomM s_s: $randomS");

    int localTime = LocalCacheUtils.getInt(LocalCacheConfig.cacheLastRankRefreshTimeKey,defaultValue: 0);
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    var betweenTime = TimeUtils.minutesBetweenTimestamps(timestamp,localTime);
    var refresh = true;
    if(betweenTime<randomM){
      refresh = false;
    }else{
      LocalCacheUtils.putInt(LocalCacheConfig.cacheLastRankRefreshTimeKey,timestamp);
    }
    LogUtils.logD("$TAG needRefresh:${refresh}");

    //用户当前 rank
    var currentUserRank = LocalCacheUtils.getInt(
      LocalCacheConfig.cacheCashCurrentKey,
      defaultValue: 0,
    );
    List<int> rangeList = [];
    if (currentUserRank == 0) {
      //第一次
      currentUserRank = random.nextInt(100) + 400;
      LocalCacheUtils.putInt(LocalCacheConfig.cacheCashCurrentKey, currentUserRank);
      LogUtils.logD("$TAG first currentUserRank:$currentUserRank");
      rangeList = generateSetWithCenter(currentUserRank,7);
      LocalCacheUtils.saveIntList(LocalCacheConfig.cacheLastRankRangeKey,rangeList);
    }else{
      if(refresh){
        currentUserRank = currentUserRank - randomS;
        LogUtils.logD("$TAG other refresh currentUserRank:$currentUserRank");
        rangeList = generateSetWithCenter(currentUserRank,7);
        LocalCacheUtils.saveIntList(LocalCacheConfig.cacheLastRankRangeKey,rangeList);
      }else{
        LogUtils.logD("$TAG other currentUserRank:$currentUserRank");
        rangeList = LocalCacheUtils.loadIntList(LocalCacheConfig.cacheLastRankRangeKey);
      }
    }

    final amounts = [500, 800, 1000];
    List<QueueUser> queue = [];

    for (int i = 0; i < rangeList.length; i++) {
      String phone = faker.phoneNumber.us();
      phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      String email = faker.internet.email();
      int amount = amounts[random.nextInt(amounts.length)];
      String formatted = rangeList[i].toString().padLeft(3, '0');
      var randomValue = random.nextInt(2);
      var account ="";
      if(randomValue == 0 ){
        account = maskPhone(phone);
      }else{
        account = maskEmail(email);
      }
      var queueUser = QueueUser(
        rank: formatted,
        account: account,
        amount: amount,
        isCurrentUser: rangeList[i] == currentUserRank,
      );
      LogUtils.logD("$TAG queueUser:${queueUser.toString()}");
      queue.add(
        queueUser,
      );
    }

    return queue;
  }

  List<int> generateSetWithCenter(int center, int length) {

    // 随机确定 center 在集合中的位置（0 ~ length-1）
    int centerIndex = random.nextInt(length);

    // 计算集合起始值
    int start = center - centerIndex;

    // 生成连续整数集合
    return List.generate(length, (i) => start + i);
  }
}
