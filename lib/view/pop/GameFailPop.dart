import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/GameConfig.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/EventConfig.dart';
import '../../utils/AudioUtils.dart';
import '../../utils/ClickManager.dart';
import '../../utils/ad/ADEnum.dart';
import '../../utils/ad/ADShowManager.dart';
import '../../utils/net/EventManager.dart';

class GameFailPop extends StatefulWidget {
  String tag;

  GameFailPop({super.key, required this.tag});

  @override
  State<GameFailPop> createState() => _GameFailPopState();
}

class _GameFailPopState extends State<GameFailPop> {
  @override
  void initState() {
    super.initState();
    AudioUtils().playTempAudio("audio/fail.mp3");
    EventManager.instance.postEvent(EventConfig.fish_die);
  }
  var allowClickAd = true;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 禁止默认返回
      onPopInvokedWithResult: (didPop, result) {},
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsetsGeometry.only(top: 252.h),
              child: GameText(showText: "app_fail_title".tr()),
            ),
          ),
          Positioned(
            left: 105.w,
            right: 105.w,
            top: 322.h,
            child: Image.asset(
              "assets/images/ic_game_fail.webp",
              width: double.infinity,
              height: 92.h,
            ),
          ),
          Positioned(
            left: 87.w,
            right: 87.w,
            top: 459.h,
            child: GameText(showText: "app_game_fail_content".tr(),strokeWidth: 1.w,strokeColor: Color(0xFFFF0066),fillColor: Colors.white,),),
          Positioned(
            right: 40.w,
            top: 539.h,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              pressedOpacity: 0.7,
              child: SizedBox(
                width: 139.w,
                height: 45.h,
                child: Stack(
                  alignment: Alignment.center, // 让子元素默认居中
                  children: [
                    Image.asset("assets/images/bg_confirm.webp"),
                    Center(
                      child: AutoSizeText(
                        "app_resurrection".tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF185F11),
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              onPressed: () {
                if (!ClickManager.canClick(context: context)) return;
                EventManager.instance.postEvent(EventConfig.fish_die_re);
                var gameData = LocalCacheUtils.getGameData();
                if (gameData.coin <= GameConfig.reviveCostCoin) {
                  GameManager.instance.showTips("app_resurrection_tips".tr());
                  return;
                }
                if(!allowClickAd)return;
                allowClickAd = false;
                ADShowManager(
                  adEnum: ADEnum.rewardedAD,
                  tag: "reward",
                  result: (type, hasValue) {
                    if (hasValue) {
                      Navigator.pop(context, 1);
                    }
                    allowClickAd = true;
                  },
                ).showScreenAD(widget.tag, awaitLoading: true);
              },
            ),
          ),
          Positioned(
            right: 32.w,
            top: 524.h,
            child: Image.asset(
              "assets/images/ic_ad_tips.webp",
              width: 36.w,
              height: 36.h,
            ),
          ),
          Positioned(
            left: 54.w,
            top: 541.h,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              pressedOpacity: 0.7,
              child: SizedBox(
                width: 115.w,
                height: 37.h,
                child: Stack(
                  alignment: Alignment.center, // 让子元素默认居中
                  children: [
                    Image.asset("assets/images/bg_fail_button.webp"),
                    Center(
                      child: AutoSizeText(
                        "app_starting_over".tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF755510),
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              onPressed: () {
                if (!ClickManager.canClick(context: context)) return;
                EventManager.instance.postEvent(EventConfig.fish_die_rebirth);
                Navigator.pop(context, 0);
              },
            ),
          ),
        ],
      ),
    );
  }
}
