import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';

import '../config/LocalCacheConfig.dart';
import '../task/CashManager.dart';
import '../task/RewardManager.dart';
import '../task/TaskManager.dart';
import 'LocalCacheUtils.dart';
import 'LogUtils.dart';
import 'RiskUserManager.dart';
import 'net/EventManager.dart';

class FishFirebaseManager{

  var TAG = "FishFirebaseManager";

  static final FishFirebaseManager instance = FishFirebaseManager._internal();

  FishFirebaseManager._internal();


  Future<void> _fetchAndInit() async {
    initFirebaseConfig("$TAG firebase get DefaultConfig");
    try {
      final success = await FirebaseRemoteConfig.instance.fetchAndActivate();
      initFirebaseConfig("$TAG firebase get RemoteConfig");
      initFirebaseConfig2();
    } catch (e) {
      LogUtils.logD("$TAG RemoteConfig fetch failed: $e");
    }
  }

  void initFirebaseConfig(String message) {
    TaskManager.instance.init(toDecode("c116_withdraw_task"));
    CashManager.instance.init(toDecode("c116_queue"));
    RewardManager.instance.init(toDecode("reward_configuration"));
    getADConfig();
  }

  Map<String, dynamic>? toDecode(String tag) {
    Map<String, dynamic>? json;
    try{
      json = jsonDecode(FirebaseRemoteConfig.instance.getString(tag));
    }catch (e){
      LogUtils.logD("$TAG RemoteConfig fetch failed: $e");
    }
    return json;
  }

  FirebaseAnalytics? analytics;
  void initFirebaseConfig2() {
    RiskUserManager.instance.init(toDecode("risk_control"));
    // 你自己的逻辑
    LogUtils.logD("$TAG initFirebaseConfig2");
  }

  Future<void> init() async {
    _fetchAndInit();
    // 捕获 Flutter 框架错误
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // 捕获 async / isolate 全局错误
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    analytics = FirebaseAnalytics.instance;
    getInstallReferrerWithRetry();
  }

  void getADConfig() {
    // Map<String, dynamic> jsonData = {};
    // try{
    //   String jsonString = FirebaseRemoteConfig.instance.getString("oxrsl_ad_config");
    //   jsonData = jsonDecode(jsonString);
    // }catch (e){
    //
    // }
    // if(jsonData.isEmpty){
    //   jsonData = CommonConfig.defaultADJson;
    // }
    // var adManager = ADLoadManager();
    // adManager.adRootData = ADData.fromJson(jsonData);
    // LogUtils.logD("ad data:${adManager.adRootData?.toJson()}");
    // ADEnum.intAD.adRequestList.clear();
    // ADEnum.rewardedAD.adRequestList.clear();
    // ADEnum.intAD.adRequestList.addAll(adManager.adRootData?.oxrslInt??[]);
    // ADEnum.rewardedAD.adRequestList.addAll(adManager.adRootData?.oxrslRv??[]);
  }

  Future<void> getInstallReferrerWithRetry({
    int maxRetry = 3,
    Duration delay = const Duration(seconds: 3),
  }) async {
    int attempt = 0;
    var cacheInstallFirst = LocalCacheUtils.getBool(LocalCacheConfig.cacheInstallFirst, defaultValue: true);
    if(!cacheInstallFirst){
      return;
    }
    while (attempt < maxRetry) {
      try {
        attempt++;
        LogUtils.logD("$TAG retry $attempt  Install Referrer...");
        final referrerDetails = await AndroidPlayInstallReferrer.installReferrer;
        LogUtils.logD("$TAG Install Referrer success: $referrerDetails");
        EventManager.instance.install(referrerDetails);
        return; // 成功直接返回
      } catch (e) {
        LogUtils.logD("$TAG Install Referrer fail: $e");
        if (attempt >= maxRetry) {
          LogUtils.logD("$TAG Install Referrer fail: max number giving up.");
          rethrow;
        }
        await Future.delayed(delay);
      }
    }
  }
}