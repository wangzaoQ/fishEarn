import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/EventConfig.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/pop/PopManger.dart';
import 'package:flutter/material.dart';

import '../config/LocalConfig.dart';
import '../data/RiskData.dart';
import '../data/UserData.dart';
import '../view/pop/ADLimitPop.dart';
import 'GlobalDataManager.dart';
import 'LogUtils.dart';
import 'RiskDeviceUtils.dart';
import 'net/EventManager.dart';

// TODO 更好包名
class RiskUserManager {
// 私有构造函数
  RiskUserManager._internal();

  // 单例实例
  static final RiskUserManager _instance = RiskUserManager._internal();

  // 获取单例
  static RiskUserManager get instance => _instance;

  RiskData? riskData;

  var TAG = "RiskUserManager:";
  static const apiKey = "OTIDAzAlLT4/Gy49HAIXOjUlMTY2JTUwJwM1Ayc1PjY1OS0YQD8XDhYMJS0XJjc7Eyc8RBgOJgASAT1bHhISLDssBDwhLCYiGUc3Jh0NOjhAOUEhRCINRwU3Xzw7QkBbFUUuLkYyMhc/ODNCTRs7AiEfNwE5BkQ3NQMxNTUlSUk=";


  void init(Map<String, dynamic>? initialTasks) async{
    // var encrypt = GlobalDataManager.instance.encrypt("MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAMYl4KczbxQYcRCOgSH0lzRtfuI/jffXOXpHUXRVm3CRiyNL4M5U0Vy3qC+HO64/a1ZZ2FFcKLG69oOvUkCuMr0CAwEAAQ==",116);
    // LogUtils.logD("${TAG}encrypt:${encrypt}");
    return;
    try{
      await RiskDeviceUtils.instance.initNumberUnit(apiKey: GlobalDataManager.instance.decrypt(apiKey,110));
    }catch (e){
      LogUtils.logD("BoRisk init error");
    }
    try{
      if (initialTasks != null) {
        riskData = RiskData.fromJson(initialTasks);
      }
    }catch (e){
      LogUtils.logE("$TAG init error $e");
    }
    if(riskData == null)return;
    LogUtils.logD("${TAG}riskData:${riskData!.toJson()}");
    upLoadInfo();
    var user = LocalCacheUtils.getUserData();
    if (user.userRiskType == 0 && user.userRiskStatus) {
      LogUtils.logD("${TAG}is risky user");
      return;
    }
    risk1(user);
  }

  //"vpn：0、1（0代表无VPN、1代表有VPN）
  //
  // root：0、1（0代表无root、1代表有root）
  //
  // sim：0、1（0代表无sim卡、1代表有sim卡）
  //
  // simulator：0、1（0代表不是模拟器、1代表是模拟器）
  //
  // googleplay：0、1（0代表不是GooglePlay安装、1代表是Google安装）
  //
  // developer：0、1（0代表不是开发者模式、1代表是开发者模式）"
  void upLoadInfo() {
    Future.microtask(() async {
      var root = await RiskDeviceUtils.instance.root();
      var vpn = await RiskDeviceUtils.instance.vpn();
      var sim = await RiskDeviceUtils.instance.sim();
      var simulator = await RiskDeviceUtils.instance.simulator();
      var store = await RiskDeviceUtils.instance.store();
      var developer = await RiskDeviceUtils.instance.developer();
      EventManager().postEvent(EventConfig.session_custom, params: {
        "root": root?1:0,
        "vpn": vpn?1:0,
        "sim": sim?1:0,
        "simulator": simulator?1:0,
        "googleplay": store?1:0,
        "developer": developer?1:0,
      });

    });
  }
  //    "vpn",
  //     "root",
  //     "sim",
  //     "simulator",
  //     "googleplay",
  //     "developer",
  //     "ip"
  void risk1(UserData user) {
    Future.microtask(() async {
      if(riskData == null)return;
      if(riskData!.ui.device == 1){
        //root
        var root = await RiskDeviceUtils.instance.root();
        if(riskData!.device.contains("root") && root){
          updateUser(user,"root");
          return;
        }
        //vpn
        var vpn = await RiskDeviceUtils.instance.vpn();
        if(riskData!.device.contains("vpn") && vpn){
          updateUser(user,"vpn");
          return;
        }
        //sim
        var sim = await RiskDeviceUtils.instance.sim();
        if(riskData!.device.contains("sim") && !sim){
          updateUser(user,"sim");
          return;
        }
        //simulator
        var simulator = await RiskDeviceUtils.instance.simulator();
        if(riskData!.device.contains("simulator") && simulator){
          updateUser(user,"simulator");
          return;
        }
        // google store
        var store = await RiskDeviceUtils.instance.store();
        if(riskData!.device.contains("googleplay") && !store){
          updateUser(user,"googleplay");
          return;
        }
        // developer
        var developer = await RiskDeviceUtils.instance.developer();
        if(riskData!.device.contains("developer") && developer){
          updateUser(user,"developer");
          return;
        }
      }
      if(risk3(user)) return;
      if (riskData!.device.contains("ip") &&
          riskData!.ui.device == 1) {
        String url = "https://ip-prod.oceanearnsolitaire.com/api/ccat";
        final dio = Dio();
        try {
          // 发送 POST 请求
          final response = await dio.post(
            url,
            data: {
              'amouse': await GlobalDataManager.instance.getDeviceId(),
            },
          );
          Map<String, dynamic> dataJson = jsonDecode(
              GlobalDataManager.instance.decrypt(response.data, 10));
          var deviceType = dataJson["data"]["bmonkey"];
          LogUtils.logD("ipAllow :${deviceType}");
          if (deviceType) {
            updateUser(user, "ip");
          } else {
            risk4(user);
          }
        } catch (e) {
          LogUtils.logD("${TAG}api check ip error :${e}");
          risk4(user);
        }
      }else{
        risk4(user);
      }
    });
  }

  void updateUser(UserData user, String from) {
    try{
      user.userRiskStatus = true;
      user.userRiskType = 0;
      user.userRiskFrom = from;
      LogUtils.logD("${TAG}is risky user from:${from}");
      LocalCacheUtils.putUserData(user);
      EventManager().postEvent(
          EventConfig.risk_chance, params: {"risk_from": from});
    }catch (e){
      LogUtils.logE("${TAG}updateUser error :${e}");
    }
  }
  void updateUser2(UserData user, String from) {
    try{
      user.userRiskStatus = true;
      user.userRiskType = 1;
      user.userRiskFrom = from;
      LogUtils.logD("${TAG}is risky user from:${from}");
      LocalCacheUtils.putUserData(user);
      EventManager().postEvent(EventConfig.risk_chance, params: {"risk_from": from});
    }catch (e){
      LogUtils.logE("${TAG}updateUser2 error :${e}");
    }
  }

  bool risk3(UserData user) {
    if(user.userRiskStatus)return true;
    if(riskData == null)return false;
    if (riskData!.ui.behavior == 1) {
      var adShortShow = LocalCacheUtils.getInt(
          LocalCacheConfig.cacheAdShortShow, defaultValue: 0);
      if (adShortShow > riskData!.behavior.adShortShow.value) {
        updateUser(user, "ad_short_show");
        return true;
      }
      var adShortClose = LocalCacheUtils.getInt(
          LocalCacheConfig.cacheAdShortClose, defaultValue: 0);
      if (adShortClose > riskData!.behavior.adShortClose.value) {
        updateUser(user, "ad_short_close");
        return true;
      }
    }
    return false;
  }

  void risk4(UserData user) async {
    if(user.userRiskStatus)return;
    if(riskData == null)return;
    if(riskData!.ui.number == 0)return;
    try {
      final did = await RiskDeviceUtils.instance.getNumberUnitID(
          channel: "dd", message: "t");
      String url = "https://sg-ddi.shuzilm.cn/q";
      final dio = Dio();
      // 发送 POST 请求
      final response = await dio.post(
        url,
        data: {
          'protocol': 2,
          'pkg': "com.fishearn.rewards",
          'did': did,
        },
      );
      var deviceType = response.data["device_type"];
      LogUtils.logD("${TAG}shumeng deviceType :${deviceType}");
      if (deviceType != 0) {
        updateUser(user, "number");
      }
    } catch (e) {
      LogUtils.logD("${TAG}shumeng error :${e}");
    }
  }

  riskRewardShow() {
    if(riskData == null)return;
    var user = LocalCacheUtils.getUserData();
    if(user.userRiskStatus)return;
    var current = DateTime
        .now()
        .millisecondsSinceEpoch;
    var last = LocalCacheUtils.getInt(
        LocalCacheConfig.cacheLastRvShowTime, defaultValue: 0);
    LocalCacheUtils.putInt(LocalCacheConfig.cacheLastRvShowTime, current);
    LogUtils.logD("${TAG}riskRewardShow time:${(current - last) / 1000}");
    if ((current - last) / 1000 <
        riskData!.behavior.adShortShow.duration) {
      LogUtils.logD("${TAG}adShortShow + 1");
      var count = LocalCacheUtils.getInt(LocalCacheConfig.cacheAdShortShow);
      count++;
      LocalCacheUtils.putInt(LocalCacheConfig.cacheAdShortShow, count);
      risk3(LocalCacheUtils.getUserData());
    }
  }

  riskRewardDismiss() {
    if(riskData == null)return;
    var user = LocalCacheUtils.getUserData();
    if(user.userRiskStatus)return;
    var current = DateTime
        .now()
        .millisecondsSinceEpoch;
    var last = LocalCacheUtils.getInt(
        LocalCacheConfig.cacheLastRvShowTime, defaultValue: 0);
    LogUtils.logD("${TAG}riskRewardDismiss time:${(current - last) / 1000}");
    if ((current - last) / 1000 <
        riskData!.behavior.adShortClose.duration) {
      LogUtils.logD("${TAG}adShortClose + 1");
      var count = LocalCacheUtils.getInt(LocalCacheConfig.cacheAdShortClose);
      count++;
      LocalCacheUtils.putInt(LocalCacheConfig.cacheAdShortClose, count);
      risk3(LocalCacheUtils.getUserData());
    }
  }

  judgeWrongDeemAdMore(int cacheRewardCount) {
    if(riskData == null)return false;
    var user = LocalCacheUtils.getUserData();
    LogUtils.logD("${TAG}judgeWrongDeemAdMore");
    if(user.userRiskStatus)return;
    if(riskData!.ui.behavior != 1 )return;
    var cacheWrongDeemAdMore = LocalCacheUtils.getBool(LocalCacheConfig.cacheWrongDeemAdMore,defaultValue: true);
    if(!cacheWrongDeemAdMore){
      return;
    }
    var currentTask = LocalCacheUtils.getString(LocalCacheConfig.taskCurrentKey, defaultValue: "");
    if(cacheRewardCount > riskData!.behavior.wrongDeemAdMore && currentTask == ""){
      LocalCacheUtils.putBool(LocalCacheConfig.cacheWrongDeemAdMore, false);
      updateUser(user, "wrong_deem_ad_more");
    }
  }

  judgeWrongDeemAdLess(UserData user) {
    if(riskData == null)return false;
    if(user.userRiskStatus)return;
    if(riskData!.ui.behavior != 1 )return;
    var cacheWrongDeemAdLess = LocalCacheUtils.getBool(LocalCacheConfig.cacheWrongDeemAdLess,defaultValue: true);
    if(!cacheWrongDeemAdLess){
      return;
    }
    if (LocalCacheUtils.getInt(LocalCacheConfig.cacheRewardCount) < riskData!.behavior.wrongDeemAdLess){
      LocalCacheUtils.putBool(LocalCacheConfig.cacheWrongDeemAdLess, false);
      updateUser(user, "wrong_deem_ad_less");
    }
  }
  void judgeADShow(int cacheADShowCount) {
    if(riskData == null)return;
    if(riskData!.ui.behavior != 1 )return;
    var user = LocalCacheUtils.getUserData();
    if(user.userRiskStatus)return;
    if(cacheADShowCount> riskData!.behavior.adDailyShow-1){
      updateUser2(user, "ad_daily_show");
      EventManager().postEvent(EventConfig.see_you_tommorow);
      PopManager().show(context: LocalConfig.globalContext!, child: ADLimitPop());
    }
  }

}