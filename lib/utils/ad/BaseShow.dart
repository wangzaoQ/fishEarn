
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
    // NetControl().postEvent(PointConfig.oxrsl_ad_imp_close,params: {
    //   "ad_pos_id":showTag,
    //   "ad_code_id":adResultData.adRequestData?.zgsbckua??"",
    //   "ad_format":adResultData.adRequestData?.rnucwtgt??"",
    //   "ad_platform":adResultData.adRequestData?.hxsgrrzm??"",
    // });
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
    // NetControl().adImpression(adResultData,pointTag);
    // AFUtils.instance.logEvent(adResultData);
  }
}