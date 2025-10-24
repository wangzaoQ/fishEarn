
import 'package:applovin_max/applovin_max.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/EventConfig.dart';
import 'package:fish_earn/utils/GlobalDataManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/utils/net/EventManager.dart';
import 'package:fish_earn/view/pop/ADFailPop.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../config/LocalConfig.dart';
import '../../config/global.dart';
import '../../data/ADResultData.dart';
import '../../view/pop/BasePopView.dart';
import '../GameManager.dart';
import 'ADEnum.dart';
import 'ADLoadManager.dart';
import 'BaseShow.dart';
import 'MaxShow.dart';

class ADShowManager{
  ADEnum adEnum;
  String tag;
  Function(String type,bool hasValue) result;

  late BaseShow adShow;

   ADShowManager({
    required this.adEnum,
    required this.tag,
    required this.result,
  }) {
    adShow = MaxShow(adEnum, tag, result);
  }
  var adType = "";

  Future<void> showScreenAD(String pointTag,{awaitLoading = false,allowADChange=true}) async {
    var isInitialized = await AppLovinMAX.isInitialized()??false;
    if(!isInitialized){
      adShow.loadComplete(ADEnum.AD_SHOW_TYPE_FAILED, tag = "adk init error");
      // NetControl().postEvent(PointConfig.oxrsl_ad_impression_fail,
      //     params: {
      //       "ad_pos_id":pointTag,
      //       "msg":"uninitialized",
      //       "ad_format":"",
      //     });
      return;
    }
    var user = LocalCacheUtils.getUserData();
    if(user.userRiskStatus){
      adShow.loadComplete(ADEnum.AD_SHOW_TYPE_FAILED, tag = "is risk user:${user.userRiskFrom}");
      return;
    }
    var adSwitch = false;
    if(tag.contains("reward")){
      adSwitch = ADLoadManager.instance.adRootData?.fixrn_switch??false;
    }else if(tag.contains("int")){
      var gameData = LocalCacheUtils.getGameData();
      var allow = GlobalDataManager.instance.allowShowInt(gameData.coin);
      if(!allow){
        adShow.loadComplete(ADEnum.AD_SHOW_TYPE_FAILED, tag = "int is not allowed");
        return;
      }
    }
    if(allowADChange){
      EventManager.instance.postEvent(EventConfig.fixrn_ad_chance,params: {"ad_pos_id":pointTag});
    }

    ADResultData? adResultData ;
    adResultData = getADData(adSwitch, ADLoadManager.instance, adResultData);
    if (awaitLoading && adResultData == null) {
      if(LocalConfig.globalContext!=null){
        await BasePopView().showScaleDialog(
          context: LocalConfig.globalContext!,
          child: ADFailPop(),
        );
      }
      EasyLoading.show(status: 'app_loading'.tr());
      var count = 0;
      while (adResultData == null && count < 10) {
        await Future.delayed(const Duration(seconds: 1));
        count++;
        ADLoadManager.instance.preloadAll("no cache await");
        adResultData = getADData(adSwitch, ADLoadManager.instance, adResultData);
      }
      EasyLoading.dismiss();
    }
    if (adResultData == null) {
      if(allowADChange){
        EventManager.instance.postEvent(EventConfig.fixrn_ad_impression_fail,
            params: {
              "ad_pos_id":pointTag,
              "msg":"ad_nocache",
              "ad_format":"",
              "ad_platform":"",
        });
        if(tag.contains("reward")){
          GameManager.instance.showTips("app_ad_no_cache".tr());
        }
      }
      adShow.loadComplete(ADEnum.AD_SHOW_TYPE_FAILED, tag = "no cache");
      return;
    }
    //走通用的逻辑
    // registerPayBack(adResultData,pointTag);
    adShow.showScreenAd(adResultData,pointTag);
    ADLoadManager.instance.adCache.remove(adEnum);
  }

  ADResultData? getADData(bool adSwitch, ADLoadManager adLoadManager, ADResultData? adResultData) {
    if(adSwitch){
      var intAD = adLoadManager.getCacheAD(ADEnum.intAD);
      var rewardedAD = adLoadManager.getCacheAD(ADEnum.rewardedAD);
      var intEcpm = -1.0;
      var rewardEcpm = -1.0;
      if (intAD?.adAny is MaxAd) {
        intEcpm = (intAD!.adAny as MaxAd).revenue;
      }
      if (rewardedAD?.adAny is MaxAd) {
        rewardEcpm = (rewardedAD!.adAny as MaxAd).revenue;
      }
      if (intEcpm == -1 && rewardEcpm == -1) {
        adResultData = null;
      } else {
        adResultData = intEcpm > rewardEcpm ? intAD : rewardedAD;
      }
    }else{
      adResultData = adLoadManager.getCacheAD(adEnum);
    }
    return adResultData;
  }
  //
  // void registerPayBack(ADResultData adResultData,String pointTag) {
  //   NetControl().adImpression(adResultData,pointTag);
  // }
}