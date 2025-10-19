import 'package:applovin_max/applovin_max.dart';

class RewardedListenerDispatcher {
  static final RewardedListenerDispatcher instance = RewardedListenerDispatcher._internal();
  RewardedListenerDispatcher._internal();

  RewardedAdListener? loadListener;
  RewardedAdListener? showListener;

  RewardedAdListener get listener => RewardedAdListener(
        onAdLoadedCallback: (ad) {
          loadListener?.onAdLoadedCallback?.call(ad);
        },
        onAdLoadFailedCallback: (adUnitId, error) {
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
        onAdReceivedRewardCallback: (ad, reward) {
          showListener?.onAdReceivedRewardCallback?.call(ad, reward);
        },
      );
}
