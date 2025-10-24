import 'dart:async';

import 'package:fish_earn/config/ADCofing.dart';
import 'package:fish_earn/config/EventConfig.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/utils/TimeUtils.dart';
import 'package:fish_earn/utils/net/EventManager.dart';

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
  ADLoadManager._();

  // 全局唯一实例
  static final ADLoadManager instance = ADLoadManager._();

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

  void init(Map<String, dynamic>? initialTasks) async{
    try{
      if (initialTasks != null) {
        adRootData = ADData.fromJson(initialTasks);
      }
    }catch (e){
      LogUtils.logE("$TAG init error $e");
    }
    if(adRootData == null){
      adRootData = ADData.fromJson(ADConfig.defaultAD);
    }
    ADEnum.intAD.adRequestList.clear();
    ADEnum.rewardedAD.adRequestList.clear();
    ADEnum.intAD.adRequestList.addAll(adRootData?.fixrn_int??[]);
    ADEnum.rewardedAD.adRequestList.addAll(adRootData?.fixrn_rv??[]);
    preloadAll("init");
  }

  void preloadAD(ADEnum adType, String tag) {
    TimeUtils.dataReset();
    LogUtils.logD("$TAG:${adType.toString()} preload location:${tag}");
    if (adFilter1()) return;
    if (getCacheAD(adType) != null) return;
    loadAD(adType,true);
  }

  void loadAD(ADEnum adType,bool addRequestPoint) {
    // LogUtils.logD("$TAG: loadAD start${adType.toString()} addRequestPoint:${addRequestPoint}");
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

    LogUtils.logD("$TAG: $adEnum :-id:${data.igteaams}");

    adEnum.adLoadStatus = ADEnum.LOAD_STATUS_LOADING;

    BaseLoader adLoader = MaxLoader(data, adEnum);
    if(addRequestPoint){
      EventManager.instance.postEvent(EventConfig.ad_request,params: {
        "ad_code_id":data.igteaams,
        "ad_format":data.uwkcopbx,
        "ad_platform":data.wdlwgunk,
      });
    }
    // 启动超时计时器
    var timeoutSeconds = 60;
    timeoutTimer?.cancel();
    timeoutTimer = Timer(Duration(seconds: timeoutSeconds), () {
      // 超时处理：把这次请求当作失败（并上报），释放锁或继续下一个候选
      LogUtils.logD(" LoadFail:$adEnum -enum:${adEnum.toString()} TIMEOUT after ${timeoutSeconds}s for adUnit=${data.igteaams}");
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
        EventManager.instance.postEvent(EventConfig.fixrn_ad_return,params: {
          "ad_code_id":data.igteaams,
          "ad_format":data.uwkcopbx,
          "ad_platform":data.wdlwgunk,
          "ad_request_time":result.adRequestTime
        });
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
    onAdCountChanged(cacheADShowCount);
  }

  /// adCount 改变时调用，例如观看一条广告就 +1
  void onAdCountChanged(int adCount) {
    // 当前 adCount 属于哪个档位：
    // 每 5 算 1 档，例如 12 → level = 2（表示已达 10）
    int currentLevel = adCount ~/ 5;
    int lastAdTriggerLevel = LocalCacheUtils.getInt(LocalCacheConfig.cacheADTargetIndex,defaultValue: 0);
    // 如果当前档位比之前更高，说明达到新上报点
    if (currentLevel > lastAdTriggerLevel) {
      // 逐档上报，防止一次跳太多漏上报
      for (int level = lastAdTriggerLevel + 1; level <= currentLevel; level++) {
        EventManager.instance.postEvent(EventConfig.pv_dall,params: {"ad":level*5});
      }
      // 更新进度
      LocalCacheUtils.putInt(LocalCacheConfig.cacheADTargetIndex,lastAdTriggerLevel);
    }
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