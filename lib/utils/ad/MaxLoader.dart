import 'package:applovin_max/applovin_max.dart';
import '../../data/ADResultData.dart';
import '../LogUtils.dart';
import 'BaseLoader.dart';
import 'maxListener/InterstitialListenerDispatcher.dart';
import 'maxListener/RewardedListenerDispatcher.dart';

class MaxLoader extends BaseLoader {

  var TAG ="ADManager";

  MaxLoader(super.requestBean, super.adEnum);

  @override
  void intAD() {
    var startTime = DateTime
        .now()
        .millisecondsSinceEpoch;
    InterstitialListenerDispatcher.instance.loadListener = InterstitialListener(
      onAdLoadedCallback: (ad) {
        // Interstitial ad is ready to show. AppLovinMAX.isInterstitialReady(_interstitial_ad_unit_ID) now returns 'true'.
        LogUtils.logD('$TAG Interstitial ad loaded from ' + ad.networkName);
        successCallBack(
          ADResultData()
            ..adRequestData = requestBean
            ..adType = requestBean.rnucwtgt
            ..adRequestTime = ((DateTime
                .now()
                .millisecondsSinceEpoch - startTime) ~/ 1000),
        );
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        loadFailed(error.message, failedCallBack);
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) {},
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {},
    );
    // Load the first interstitial.
    AppLovinMAX.loadInterstitial(requestBean.zgsbckua);
  }

  @override
  void rewarded() {
    var startTime = DateTime
        .now()
        .millisecondsSinceEpoch;
    RewardedListenerDispatcher.instance.loadListener =  RewardedAdListener(onAdLoadedCallback: (ad) {
      successCallBack(
        ADResultData()
          ..adRequestData = requestBean
          ..adType = requestBean.rnucwtgt
          ..adRequestTime = ((DateTime
              .now()
              .millisecondsSinceEpoch - startTime) ~/ 1000),
      );
      // Rewarded ad is ready to show. AppLovinMAX.isRewardedAdReady(_rewarded_ad_unit_ID) now returns 'true'.
    },
        onAdLoadFailedCallback: (adUnitId, error) {
          loadFailed(error.message, failedCallBack);
        },
        onAdDisplayedCallback: (ad) {
        },
        onAdDisplayFailedCallback: (ad, error) {
        },
        onAdClickedCallback: (ad) {
        },
        onAdHiddenCallback: (ad) {
        },
        onAdReceivedRewardCallback: (ad, reward) {

        });
    AppLovinMAX.loadRewardedAd(requestBean.zgsbckua);

  }

}