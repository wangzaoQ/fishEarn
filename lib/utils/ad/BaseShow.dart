
import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:fish_earn/utils/net/EventManager.dart';

import '../../config/global.dart';
import '../../data/ADResultData.dart';
import '../LogUtils.dart';
import '../RiskUserManager.dart';
import 'ADEnum.dart';
import 'ADLoadManager.dart';

abstract class BaseShow {

  var TAG ="ADManager";


  final ADEnum adEnum;
  final String showTag;
  final void Function(String type,bool hasValue) result;

  BaseShow(this.adEnum, this.showTag, this.result);

  var hasValue = false;

  // 抽象方法
  void showScreenAd(ADResultData adResultData, String pointTag);


  // 广告展示失败处理
  void adShowFailed(ADEnum adEnum, String tag) {
    adIsPlay = false;
    LogUtils.logD("App adShowFailed isPlay:${adIsPlay}");
    loadComplete(ADEnum.AD_SHOW_TYPE_FAILED, tag);
  }

  // 全屏广告关闭
  void adDismissFullScreen(ADEnum adEnum, String tag,ADResultData adResultData) {
    adIsPlay = false;
    LogUtils.logD("App adDismissFullScreen isPlay:${adIsPlay}");
    LogUtils.logD("$TAG adDismissFullScreen tag:$tag adEnum:${adEnum.toString()}");
    loadComplete(ADEnum.AD_SHOW_TYPE_SUCCESS, tag);
    setADDismissTime();
    if(showTag.contains("reward")){
      RiskUserManager.instance.riskRewardDismiss();
    }
  }

  // 全屏广告展示
  void adShowFullScreen(ADEnum adEnum, String tag, ADResultData adResultData, String pointTag) {
    adIsPlay = true;
    LogUtils.logD("$TAG App adShowFullScreen isPlay:${adIsPlay}");
    LogUtils.logD("$TAG adShowFullScreen tag:$tag adEnum:${adEnum.toString()}");
    ADLoadManager().addShowNumber();
    if(showTag.contains("reward")){
      RiskUserManager.instance.riskRewardShow();
    }
    addADEvent(adResultData,pointTag);
  }

  // 通知加载完成
  void loadComplete(String type, String tag) {
    adIsPlay = false;
    LogUtils.logD("$TAG loadComplete tag:$tag adEnum:${adEnum.toString()}");
    ADLoadManager().preloadAll("loadComplete");
    result(type,hasValue);
  }

  // 需你实现的逻辑
  void setADDismissTime() {
  }
  void addADEvent(ADResultData adResultData,String pointTag) {
    EventManager.instance.adImpression(adResultData,pointTag);
    sendAdToSdk(adResultData);
    // AFUtils.instance.logEvent(adResultData);
  }

  sendAdToSdk(ADResultData adResultData) {
    try {
      var max = (adResultData.adAny) as MaxAd;
      AdjustAdRevenue adjustAdRevenue = AdjustAdRevenue('applovin_max_sdk');
      adjustAdRevenue.setRevenue(max.revenue, 'USD');
      adjustAdRevenue.adRevenueNetwork = max.networkPlacement;
      adjustAdRevenue.adRevenuePlacement = max.placement;
      Adjust.trackAdRevenue(adjustAdRevenue);
      LogUtils.logD("af logs:: af revenue success ${max.revenue}");
    } catch (e) {
      LogUtils.logD("af logs:: af revenue error $e");
    }

    // FacebookAppEvents fb = FacebookAppEvents();
    // fb.logPurchase(amount: max.revenue, currency: "USD");
  }
}