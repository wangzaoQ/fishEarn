import 'dart:async';

import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/utils/TimeUtils.dart';

import '../../data/ADRequestData.dart';
import '../../data/ADResultData.dart';
import '../LogUtils.dart';
import '../RiskUserManager.dart';
import 'ADEnum.dart';
import 'BaseLoader.dart';
import 'MaxLoader.dart';

class ADLoadManager {

  var TAG ="ADManager";

  // 私有构造函数
  ADLoadManager._internal();

  // 静态实例（懒加载，推荐）
  static final ADLoadManager _instance = ADLoadManager._internal();


  // 工厂构造函数，返回唯一实例
  factory ADLoadManager() => _instance;

  // 对外暴露的变量
  ADData? adRootData;
  final Map<ADEnum, ADResultData> adCache = {};
  //"pv_numbers:
  // 5,10,15,20,25,30,35,40,45,50"
  var targets = [5, 10, 15, 20, 25,30,35,40,45,50];

  var targetIndex = LocalCacheUtils.getInt(
    LocalCacheConfig.cacheADTargetIndex,
    defaultValue: 0,
  );
  Timer? timeoutTimer;

  void initConfig() {}

  void preloadAD(ADEnum adType, String tag) {
    TimeUtils.dataReset();
    LogUtils.logD("$TAG:${adType.toString()} preload location:${tag}");
    if (adFilter1()) return;
    if (getCacheAD(adType) != null) return;
    loadAD(adType,true);
  }

  void loadAD(ADEnum adType,bool addRequestPoint) {
    LogUtils.logD("$TAG: loadAD start${adType.toString()} addRequestPoint:${addRequestPoint}");
    if (adType.adLoadStatus == ADEnum.LOAD_STATUS_LOADING) return;
    var user = LocalCacheUtils.getUserData();
    if(user.userRiskStatus){
      LogUtils.logD("$TAG:is risk user ${user.userRiskFrom}");
      return;
    }
    var list = List<ADRequestData>.from(adType.adRequestList);
    load(adType, list,addRequestPoint);
  }

  void load(ADEnum adEnum, List<ADRequestData> list,bool addRequestPoint) {
    LogUtils.logD("$TAG: load start${adEnum.toString()} addRequestPoint:${addRequestPoint}list:${list}");
    if (list.isEmpty) {
      adEnum.adLoadStatus = ADEnum.AD_LOAD_FAIL;
      return;
    }

    final data = list.removeAt(0);

    LogUtils.logD("$TAG: $adEnum :-id:${data.zgsbckua}");

    adEnum.adLoadStatus = ADEnum.LOAD_STATUS_LOADING;

    BaseLoader adLoader = MaxLoader(data, adEnum);
    if(addRequestPoint){
      // NetControl().postEvent(PointConfig.ad_request,params: {
      //   "ad_code_id":data.zgsbckua??"",
      //   "ad_format":data.rnucwtgt??"",
      //   "ad_platform":data.hxsgrrzm??"",
      // });
    }
    // 启动超时计时器
    var timeoutSeconds = 60;
    timeoutTimer?.cancel();
    timeoutTimer = Timer(Duration(seconds: timeoutSeconds), () {
      // 超时处理：把这次请求当作失败（并上报），释放锁或继续下一个候选
      LogUtils.logD(" LoadFail:$adEnum -enum:${adEnum.toString()} TIMEOUT after ${timeoutSeconds}s for adUnit=${data.zgsbckua}");
      adEnum.adLoadStatus = ADEnum.AD_LOAD_FAIL;
      // 上报一个超时事件（可选）
      // NetControl().postEvent(PointConfig.ad_request, params: {
      //   "reqId": reqId,
      //   "ad_code_id": data.zgsbckua ?? "",
      //   "event": "timeout",
      // });
      //
      // // 继续尝试下一个（使用本地 list）
      // if (list.isNotEmpty) {
      //   _loadChainWithTimeout(adEnum, list, timeoutSeconds: timeoutSeconds);
      // } else {
      //   _loadingLock[adEnum] = false;
      // }
    });
    adLoader
      ?..setSuccessCall((result) {
        timeoutTimer?.cancel();
        saveCacheAD(adEnum, result);
        adEnum.adLoadStatus = ADEnum.AD_LOAD_SUCCESS;
        // NetControl().postEvent(PointConfig.oxrsl_ad_return,params: {
        //   "ad_code_id":result.adRequestData?.zgsbckua??"",
        //   "ad_format":result.adRequestData?.rnucwtgt??"",
        //   "ad_platform":result.adRequestData?.hxsgrrzm??"",
        //   "ad_request_time":result.adRequestTime
        // });
        LogUtils.logD(
          "${TAG} LoadSuccess:$adEnum -enum:${adEnum.toString()} -time:${result.adRequestTime}",
        );
      })
      ..setFailedCall((error) {
        timeoutTimer?.cancel();
        adEnum.adLoadStatus = ADEnum.AD_LOAD_FAIL;
        loadAD(adEnum,false); // 递归重试
        LogUtils.logD(
          "${TAG} LoadFail:$adEnum -enum:${adEnum.toString()} -message:${error}",
        );
      })
      ..startLoadAD();
  }

  void saveCacheAD(ADEnum adEnum, ADResultData adResultData) {
    // LogUtils.logD(
    //   "${AD_LOAD_TAG} putCache enum:${adEnum.toString()} oldSize:${adCache.length}",
    // );
    adCache[adEnum] = adResultData;
    LogUtils.logD(
      "${TAG} putCache enum:${adEnum.toString()} newSize:${adCache.length}",
    );
  }

  ADResultData? getCacheAD(ADEnum adType) {
    final adPreloadBean = adCache[adType];
    if (adPreloadBean!=null && adPreloadBean.adRequestData == null) {
      LogUtils.logD(
        "${TAG} getCache adRequestData == null",
      );
      adCache.remove(adType);
      return null;
    }
    return adPreloadBean;
  }

  bool adFilter1() {
    TimeUtils.dataReset();
    return false;
  }

  void addShowNumber() {
    var cacheADShowCount = LocalCacheUtils.getInt(LocalCacheConfig.cacheADShowCount,defaultValue: 0);
    cacheADShowCount+=1;
    LocalCacheUtils.putInt(LocalCacheConfig.cacheADShowCount, cacheADShowCount);
    RiskUserManager.instance.judgeADShow(cacheADShowCount);
    // while (targetIndex < targets.length &&
    //     cacheADShowCount >= targets[targetIndex]) {
    //   targetIndex++;
    //   LocalCacheUtils.putInt(
    //     CacheConfig.cacheADTargetIndex,
    //     targetIndex,
    //   );
    //   NetControl().postEvent(PointConfig.pv_dall,params: {"pv_numbers":targets[targetIndex]});
    // }
  }
  void addClickNumber() {
    var cacheADClickCount = LocalCacheUtils.getInt(LocalCacheConfig.cacheADClickCount,defaultValue: 0);
    cacheADClickCount+=1;
    LocalCacheUtils.putInt(LocalCacheConfig.cacheADClickCount, cacheADClickCount);
  }

  void preloadAll(String tag) {
    preloadAD(ADEnum.intAD,tag);
    preloadAD(ADEnum.rewardedAD,tag);
  }
}