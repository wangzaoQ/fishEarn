import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/data/ADResultData.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/utils/net/HttpManager.dart';
import 'package:fish_earn/utils/net/NetParamsManager.dart';
import 'package:flutter_tba_info/flutter_tba_info.dart';

import '../LogUtils.dart';

class EventManager {
  // 私有构造函数
  EventManager._();

  // 全局唯一实例
  static final EventManager instance = EventManager._();

  // 公共访问点
  factory EventManager() {
    return instance;
  }

  void session() {
    LogUtils.logD("postEvent key: session");
    Future(() async {
      var map = await NetParamsManager.instance.getCommonJson();
      map["pagoda"] = {};
      HttpManager.dio.post("", data: map).catchError((e) {
        LogUtils.logE("error:${e}");
      });
    });
  }

  void adImpression(ADResultData adResultData, String pointTag) {
    LogUtils.logD("postEvent key:adImpression");
    Future(() async{
      var ad = (adResultData.adAny) as MaxAd;
      var map = await NetParamsManager.instance.getCommonJson();
      map["aurora"] = ad.revenue* 1_000_000;
      map["ulster"] = "USD";
      map["smithy"] = ad.networkName;
      map["jackass"] = "max";
      map["squadron"] = adResultData.adRequestData?.igteaams??"";
      map["sickish"] = adResultData.adType;
      map["peroxide"] = ad.revenuePrecision;
      map["chair"] = pointTag;
      map["ak"] = "throng";

      HttpManager.dio.post("",data: map).catchError((e){
        LogUtils.logE("error:${e}");
      });
    });
  }

  void install(ReferrerDetails referrerDetails) {
    LogUtils.logD("postEvent key: install");
    Future(() async {
      var commonJson = await NetParamsManager.instance.getCommonJson();
      var map = {};
      map["mukluk"] = await NetParamsManager.instance.getBuildId();
      map["werther"] = referrerDetails.installReferrer ?? "";
      map["sideshow"] = await NetParamsManager.instance.getWebViewUserAgent();
      map["hold"] = "millard";
      map["softball"] = referrerDetails.referrerClickTimestampSeconds;
      map["smelt"] = referrerDetails.installBeginTimestampSeconds;
      map["lampoon"] = referrerDetails.referrerClickTimestampServerSeconds;
      map["kept"] = referrerDetails.installBeginTimestampServerSeconds;
      var mapRefer = await FlutterTbaInfo().getReferrerMap();
      map["accent"] = mapRefer["install_first_seconds"];
      map["line"] = mapRefer["last_update_seconds"];
      commonJson["sight"] = map;
      HttpManager.dio
          .post("", data: commonJson)
          .then((response) {
            if(response.statusCode == 0 || response.statusCode == 200){
              LocalCacheUtils.putBool(LocalCacheConfig.cacheInstallFirst, false);
            }
          })
          .catchError((e) {
            LogUtils.logE("error:${e}");
          });
    });
  }

  void postEvent(
    String key, {
    Map<String, dynamic>? params,
    void Function(dynamic data)? onResult,
  }) {
    LogUtils.logD("postEvent key:${key} params:${params}");
    Future(() async {
      var map = await NetParamsManager.instance.getCommonJson();
      map["ak"] = key;
      // params?.forEach((key, value) {
      //   map['$key'] = value;
      // });
      map["bater"] = params;
      HttpManager.dio.post("", data: map).catchError((e) {
        LogUtils.logE("error:$e");
      });
      if (onResult != null) {}
    });
    // FirebaseManager.instance.analytics?.logEvent(
    //   name: key,
    //   parameters: params?.cast<String, Object>(),
    // ).catchError((e){
    //   LogUtils.logE("error:$e");
    // });
  }

}
