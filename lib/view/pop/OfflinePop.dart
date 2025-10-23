import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/task/CashManager.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/EventConfig.dart';
import '../../data/GameData.dart';
import '../../task/RewardManager.dart';
import '../../utils/ClickManager.dart';
import '../../utils/ad/ADEnum.dart';
import '../../utils/ad/ADShowManager.dart';
import '../../utils/net/EventManager.dart';

class OfflinePop extends StatefulWidget {
  const OfflinePop({super.key});

  @override
  State<OfflinePop> createState() => _OfflinePopState();
}

class _OfflinePopState extends State<OfflinePop> {


  int level = 2;
  double coin = 0.0;

  @override
  void initState() {
    super.initState();
    var gameData = LocalCacheUtils.getGameData();
    level = gameData.level;
    coin = RewardManager.instance.findReward(RewardManager.instance.rewardData?.oldUsersAward?.prize, gameData.coin);
    EventManager.instance.postEvent(EventConfig.old_users_award);
  }

  var allowClickProtect = true;

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, // 禁止默认返回
        onPopInvokedWithResult: (didPop, result) {
          toBack();
        },
        child:Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 240.h),
            child: Image.asset(
              "assets/images/ic_offline_title.webp",
              width: 254.w,
              height: 22.h,
              fit: BoxFit.fill,
            ),
          ),
        ),

        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 220.h),
            child:SizedBox(width: double.infinity,height: 325.h,child:Stack(
              children: [
                Image.asset(
                  level == 2?"assets/images/bg_level2_old_game.webp":"assets/images/bg_level3_old_game.webp",
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                ),
              ],
            )),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 284.h),
            child: Text(
              "app_offline_title".tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontFamily: "AHV",
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 540.h),
            child:  GameText(
              showText: "+\$${GameManager.instance.getCoinShow(coin)}",
              fontSize: 20.sp,
              fillColor: Color(0xFFFFEF50),
              strokeColor: Color(0xFF9B4801),
              strokeWidth: 1.w,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 580.h),
            child:  CupertinoButton(
              padding: EdgeInsets.zero,
              pressedOpacity: 0.7,
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child:Stack(
                  alignment: Alignment.center, // 让子元素默认居中
                  children: [
                    Image.asset(
                      "assets/images/bg_confirm.webp",
                      fit: BoxFit.fill,
                    ),
                    AutoSizeText(
                      "${"app_claim".tr()} 200%",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF185F11),
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              onPressed: () {
                if (!ClickManager.canClick(context: context)) return;
                if (!allowClickProtect) return;
                allowClickProtect = false;
                EventManager.instance.postEvent(EventConfig.old_users_award_2x);
                ADShowManager(
                  adEnum: ADEnum.rewardedAD,
                  tag: "reward",
                  result: (type, hasValue) {
                    allowClickProtect = true;
                    if (hasValue) {
                      var gameData = LocalCacheUtils.getGameData();
                      gameData.coin+=coin*2;
                      LocalCacheUtils.putGameData(gameData);
                      Navigator.pop(context,1);
                    }
                  },
                ).showScreenAD(EventConfig.fixrn_offline_rv, awaitLoading: true);
              },
            ),
          ),
        ),
        Positioned(
          right: 100.w,
          top: 565.h,
          child: Image.asset(
            "assets/images/ic_ad_tips.webp",
            width: 36.w,
            height: 36.h,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(bottom: 100.h),
            child: CupertinoButton(
              onPressed: () {
                if (!ClickManager.canClick(context: context)) return;
                toBack();
              },
              child: Text(
                "${"app_only".tr()} +\$${coin}",
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Color(0xFFBFC3C7),
                  decoration: TextDecoration.underline,
                  // ✅ 下划线
                  decorationColor: Color(0xBFFFFFFF),
                  // 可选：自定义下划线颜色
                  decorationThickness: 1.h,
                ),
              ),
            ),
          ),
        )
      ],
    ));
  }

  var back = true;
  void toBack() {
    if(!back)return;
    back = false;
    ADShowManager(
      adEnum: ADEnum.intAD,
      tag: "int",
      result: (type, hasValue) {
        if(!mounted)return;
        EventManager.instance.postEvent(EventConfig.old_users_award_1x);
        var gameData = LocalCacheUtils.getGameData();
        gameData.coin+=coin;
        LocalCacheUtils.putGameData(gameData);
        Navigator.pop(context, 0);
      },
    ).showScreenAD(EventConfig.fixrn_wheel_int);
  }
}
