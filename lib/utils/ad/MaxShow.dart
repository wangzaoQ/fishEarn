import 'package:applovin_max/applovin_max.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/utils/RiskUserManager.dart';
import '../../config/LocalConfig.dart';
import '../../data/ADResultData.dart';
import 'ADLoadManager.dart';
import 'BaseShow.dart';
import 'maxListener/InterstitialListenerDispatcher.dart';
import 'maxListener/RewardedListenerDispatcher.dart';

class MaxShow extends BaseShow {
  MaxShow(super.adEnum, super.tag, super.result);

  @override
  Future<void> showScreenAd(ADResultData adResultData, String pointTag) async {
    var from = adResultData.adRequestData?.rnucwtgt ?? "";
    switch (from) {
      case LocalConfig.int:
         InterstitialListenerDispatcher.instance.showListener = InterstitialListener(
          onAdLoadedCallback: (ad) {},
          onAdLoadFailedCallback: (adUnitId, error) {},
          onAdDisplayedCallback: (ad) {
            if(showTag.contains("reward")){
              hasValue=true;
            }
            adResultData.adAny = ad;
            adShowFullScreen(adEnum, "max int ad show",adResultData,pointTag);
          },
          onAdDisplayFailedCallback: (ad, error) {
            // NetControl().postEvent(PointConfig.oxrsl_ad_impression_fail,params: {
            //   "ad_pos_id":pointTag,
            //   "msg":"impfail",
            //   "ad_format":adResultData.adRequestData?.rnucwtgt??"",
            // });
            adShowFailed(adEnum, "max int ad show error");
          },
          onAdClickedCallback: (ad) {
            ADLoadManager().addClickNumber();
          },
          onAdHiddenCallback: (ad) {
            adDismissFullScreen(adEnum,"max int ad dismiss",adResultData);
          },
        );
        AppLovinMAX.setInterstitialListener(InterstitialListenerDispatcher.instance.listener);
        bool isReady = (await AppLovinMAX.isInterstitialReady(
          adResultData.adRequestData?.zgsbckua ?? "",
        ))!;
        if (isReady) {
          AppLovinMAX.showInterstitial(
            adResultData.adRequestData?.zgsbckua ?? "",
          );
        }else{
          // NetControl().postEvent(PointConfig.oxrsl_ad_impression_fail,params: {
          //   "ad_pos_id":pointTag,
          //   "msg":"notPrepared",
          //   "ad_format":adResultData.adRequestData?.rnucwtgt??"",
          // });
          adShowFailed(adEnum, "max int ad isReady = false");
        }
        break;
      case LocalConfig.reward:

        RewardedListenerDispatcher.instance.showListener =  RewardedAdListener(
            onAdLoadedCallback: (ad) {
        },
            onAdLoadFailedCallback: (adUnitId, error) {
            },
            onAdDisplayedCallback: (ad) {
              adResultData.adAny = ad;
              adShowFullScreen(adEnum, "max reward ad show",adResultData,pointTag);
            },
            onAdDisplayFailedCallback: (ad, error) {
              // NetControl().postEvent(PointConfig.oxrsl_ad_impression_fail,params: {
              //   "ad_pos_id":pointTag,
              //   "msg":"impfail",
              //   "ad_format":adResultData.adRequestData?.rnucwtgt??"",
              // });
              adShowFailed(adEnum, "max reward ad show error");
            },
            onAdClickedCallback: (ad) {
              ADLoadManager().addClickNumber();
            },
            onAdHiddenCallback: (ad) {
              adDismissFullScreen(adEnum,"max reward ad dismiss",adResultData);
            },
            onAdReceivedRewardCallback: (ad, reward) {
              hasValue=true;
              var cacheRewardCount = LocalCacheUtils.getInt(LocalCacheConfig.cacheRewardCount);
              cacheRewardCount++;
              LocalCacheUtils.putInt(LocalCacheConfig.cacheRewardCount, cacheRewardCount);
              RiskUserManager.instance.judgeWrongDeemAdMore(cacheRewardCount);
            });
        AppLovinMAX.setRewardedAdListener(RewardedListenerDispatcher.instance.listener);

        bool isReady = (await AppLovinMAX.isRewardedAdReady(adResultData.adRequestData?.zgsbckua ?? ""))!;
        if (isReady) {
          AppLovinMAX.showRewardedAd(adResultData.adRequestData?.zgsbckua ?? "");
        }else{
          // NetControl().postEvent(PointConfig.oxrsl_ad_impression_fail,params: {
          //   "ad_pos_id":pointTag,
          //   "msg":"notPrepared",
          //   "ad_format":adResultData.adRequestData?.rnucwtgt??"",
          // });
          adShowFailed(adEnum, "max reward ad isReady = false");
        }
        break;
    }
  }
}
