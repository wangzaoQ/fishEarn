import 'package:applovin_max/applovin_max.dart';

import '../../LogUtils.dart';


class InterstitialListenerDispatcher {

  static final InterstitialListenerDispatcher instance = InterstitialListenerDispatcher._internal();

  InterstitialListenerDispatcher._internal();

  InterstitialListener? loadListener;
  InterstitialListener? showListener;

  InterstitialListener get listener => InterstitialListener(
        onAdLoadedCallback: (ad) {
          LogUtils.logD("AD_LOAD_TAG ad load success");
          loadListener?.onAdLoadedCallback?.call(ad);
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          LogUtils.logD("AD_LOAD_TAG ad load error:${error.message}");
          loadListener?.onAdLoadFailedCallback?.call(adUnitId, error);
        },
        onAdDisplayedCallback: (ad) {
          showListener?.onAdDisplayedCallback?.call(ad);
        },
        onAdDisplayFailedCallback: (ad, error) {
          showListener?.onAdDisplayFailedCallback?.call(ad, error);
        },
        onAdClickedCallback: (ad) {
          showListener?.onAdClickedCallback?.call(ad);
        },
        onAdHiddenCallback: (ad) {
          showListener?.onAdHiddenCallback?.call(ad);
        },
      );
}
